Application.put_env(:exla, :clients,
  default: [platform: :host],
  cuda: [platform: :cuda]
)

{:ok, img} = Excv.imread("Pelemay.png")

img
|> GammaExcv.gamma_map(0.5)
|> Excv.imwrite("/tmp/Pelemay_gamma.png")

defmodule GammaExla do
  import Nx.Defn

  @defn_compiler EXLA
  defn(host(img, gamma), do: GammaExcv.gamma_pipelined_defn(img, gamma))

  @defn_compiler {EXLA, client: :cuda}
  defn(cuda(img, gamma), do: GammaExcv.gamma_pipelined_defn(img, gamma))

  @defn_compiler {EXLA, client: :cuda, run_options: [keep_on_device: true]}
  defn(cuda_keep(img, gamma), do: GammaExcv.gamma_pipelined_defn(img, gamma))
end

benches = %{
  "gamma_map (def)" => fn -> GammaExcv.gamma_map(img, 0.5) end,
  "gamma_map_pipelined (def)" => fn -> GammaExcv.gamma_map_pipelined(img, 0.5) end,
  "gamma_pipelined_def" => fn -> GammaExcv.gamma_pipelined_def(img, 0.5) end,
  "gamma_pipelined_defn (Nx)" => fn -> GammaExcv.gamma_pipelined_defn(img, 0.5) end,
  "gamma_pipelined_defn (EXLA cpu)" => fn -> GammaExla.host(img, 0.5) end
}

benches =
  if System.get_env("EXLA_TARGET") == "cuda" do
    dimg = Nx.backend_transfer(img, {EXLA.DeviceBackend, client: :cuda})
    dgamma = Nx.backend_transfer(Nx.tensor(0.5), {EXLA.DeviceBackend, client: :cuda})

    Map.merge(benches, %{
      "gamma_pipelined_defn (EXLA gpu) gamma on host" => fn -> GammaExla.cuda(dimg, 0.5) end,
      "gamma_pipelined_defn (EXLA gpu) gamma on gpu" => fn -> GammaExla.cuda(dimg, dgamma) end,
      "gamma_pipelined_defn (EXLA gpu keep) gamma on host" => fn ->
        GammaExla.cuda_keep(dimg, 0.5)
      end,
      "gamma_pipelined_defn (EXLA gpu keep) gamma on gpu" => fn ->
        GammaExla.cuda_keep(dimg, dgamma)
      end
    })
  else
    benches
  end

Benchee.run(
  benches,
  time: 10,
  memory_time: 2
)
