defmodule ZaxxonTest do
  use ExUnit.Case
  use Tensor
  doctest Zaxxon

  @zax %Zaxxon{
    threshold_matrix: [
      [0.5, 0.5],
      [0.5, 0.5],
    ],
    weights_matrix: [
      [0.5, 0.5],
      [0.5, 0.5],
    ]
  }

  @vector Vector.new([
    0.5,
    0.5,
  ])

  @matrix Matrix.new([
    [0.5, 0.5],
    [0.5, 0.5],
    [0.5, 0.5]
  ], 3, 2)


  @tensor Tensor.new([
    [
      [0.5, 0.5],
      [0.5, 0.5],
      [0.5, 0.5]
    ],
    [
      [0.5, 0.5],
      [0.5, 0.5],
      [0.5, 0.5]
    ],
  ], [2, 3, 2])

  defp row_sum(zax = %Zaxxon{}, row) do
    zax[:weigths_matrix]
    |> Enum.at(row)
    |> List.foldr(0, fn(acc, x) -> x + acc end)
  end


  test "Perturb a tensor" do
    v = Zaxxon.perturb(@vector, 0.001, 0.05)
    m = Zaxxon.perturb(@matrix, 0.001, 0.05)
    t = Zaxxon.perturb(@tensor, 0.001, 0.05)
    assert Vector.vector?(v)
    assert v != @vector
    assert Matrix.matrix?(m)
    assert m != @matrix
    refute Matrix.matrix?(t)
    assert t != @tensor
  end

  test "Perturb a zaxxon" do
    zax_out = Zaxxon.perturb(@zax, 0.001, 0.05)
    zax_out_again = Zaxxon.perturb(@zax, 0.001, 0.05)
    assert @zax != zax_out
    assert zax_out != zax_out_again
    assert row_sum(zax_out, 0) == 1
    assert row_sum(zax_out, 1) == 1
  end
end
