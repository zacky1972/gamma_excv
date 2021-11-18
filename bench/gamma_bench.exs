{:ok, img} = Excv.imread("Pelemay.png")

img
|> GammaExcv.gamma_map(0.5)
|> Excv.imwrite("/tmp/Pelemay_gamma.png")

benches = %{
  "gamma_map" => fn -> GammaExcv.gamma_map(img, 0.5) end
}

Benchee.run(
  benches,
  time: 10,
  memory_time: 2
)
