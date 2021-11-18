defmodule GammaExcv do
  @moduledoc """
  Documentation for `GammaExcv`.
  """

  @spec gamma_map(Nx.Tensor.t(), number) :: Nx.Tensor.t()
  def gamma_map(image, gamma) do
    image
    |> Nx.map(
      [type: {:f, 32}],
      &Nx.multiply(255, Nx.power(Nx.divide(&1, 255), Nx.divide(1, gamma)))
    )
    |> Nx.as_type({:u, 8})
  end
end
