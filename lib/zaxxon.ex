defmodule Zaxxon do
  @moduledoc """
  Documentation for Zaxxon.

  Threshold matrix:

    input layer   t_11 t_12 t_13
    hidden layer  t_21 t_22 t_23
    output layer  t_31 t_32 t_33

    indices are <layer><node>
    for n layers and m nodes per layer an n x m matrix

    Weights tensor:

        w_111  w_112  w_113
      w_121  w_122  w_123
    w_131  w_132  w_133

        w_211  w_212  w_213
      w_221  w_222  w_223
    w_231  w_232  w_233

    indices are <layer - 1><from node><to node>
    for n layers and m nodes per layer an (n - 1) x m x m tensor

  """

  use Tensor
  alias Zaxxon.Helpers

  @doc """
  Struct representing a zaxxon
  """
  defstruct threshold_matrix: Matrix.new([[0.5, 0.5]], 1, 2), weights_tensor: Tensor.new([0.1])

  @doc """
  Neuron activates if (inputs * weights) / # of inputs > threshold

  Normalizing by the number of inputs seems weird, but assuming a constant number of
  nodes per layer it seems less weird.

  ## Examples

      iex> Zaxxon.activate?([0.4, 0.2, 0.2], [0.5, 0.5, 0], 0.2)
      false

      iex> Zaxxon.activate?([0.8, 0.2, 0.2], [0.5, 0.5, 0], 0.15)
      true

  """
  def activate?(inputs, weights, threshold) do
    a = Enum.with_index(inputs)
      |> Enum.map(fn({x, i}) -> x * Enum.at(weights, i) end)
      |> List.foldr(0, fn(acc, x) -> x + acc end)
      |> Kernel./(length(inputs))
    cond do
        a > threshold -> true
        true -> false
    end
  end

  @doc """
  Apply an input vector to a Zaxxon, return the output vector

  ## Examples

      iex> Zaxxon.apply([0.7], %Zaxxon{})
      [false]

      iex> Zaxxon.apply([0.7], %Zaxxon{weights_tensor: Tensor.new([0.6], [1])})
      [true]

      iex> Zaxxon.apply([0.4], %Zaxxon{weights_tensor: Tensor.new([0.6], [1])})
      [false]
  """
  def apply(inputs, zax) do

  end

  @doc """
  Apply a scalar perturbation

  (How do you test this?)
  """
  def perturb(x, frequency, intensity) when is_number(x) do
    roll = Enum.random(1..100) / 100
    case roll > frequency do
      true ->
        case rem(round(roll * 100), 2) do
          0 -> Helpers.cap(x + intensity)
          1 -> Helpers.cap(x - intensity)
        end
      false -> x
    end
  end

  @doc """
  Perturb a zaxxon
  """
  def perturb(%Zaxxon{threshold_matrix: tm, weights_tensor: wm} = zax, frequency, intensity) do
    %Zaxxon{
      threshold_matrix: perturb(tm, frequency, intensity),
      weights_tensor: perturb(wm, frequency, intensity)
    }
  end

  @doc """
  Perturb a Tensor
  """
  def perturb(m, frequency, intensity) do
    cond do
      Vector.vector?(m) ->
        Vector.map(m, fn(x) -> perturb(x, frequency, intensity) end)
      Matrix.matrix?(m) ->
        Matrix.map(m, fn(x) -> perturb(x, frequency, intensity) end)
      length(Tensor.dimensions(m)) > 2 ->
        Tensor.map(m, fn(x) -> perturb(x, frequency, intensity) end)
      true -> :error
    end
  end

end
