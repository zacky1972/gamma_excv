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
  defn host(img, gamma), do: GammaExcv.gamma_pipelined_defn(img, gamma)
end

benches = %{
  "gamma_map (def)" => fn -> GammaExcv.gamma_map(img, 0.5) end,
  "gamma_map_pipelined (def)" => fn -> GammaExcv.gamma_map_pipelined(img, 0.5) end,
  "gamma_pipelined_def" => fn -> GammaExcv.gamma_pipelined_def(img, 0.5) end,
  "gamma_pipelined_defn (Nx)" => fn -> GammaExcv.gamma_pipelined_defn(img, 0.5) end,
  "gamma_pipelined_defn (EXLA cpu)" => fn -> GammaExla.host(img, 0.5) end
}

Benchee.run(
  benches,
  time: 10,
  memory_time: 2
)
