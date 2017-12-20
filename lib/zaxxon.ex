defmodule Zaxxon do
  @moduledoc """
  Documentation for Zaxxon.
  """

  @doc """
  Struct representing a zaxxon
  """
  defstruct threshold_matrix: [[0.5, 0.5]], weights_matrix: [1]

  @doc """
  Neuron activates if inputs * weights > threshold

  ## Examples

      iex> Zaxxon.activate?([0.4, 0.2, 0.2], [0.5, 0.5, 0], 0.4)
      false

      iex> Zaxxon.activate?([0.8, 0.2, 0.2], [0.5, 0.5, 0], 0.4)
      true
  """
  def activate?(inputs, weights, threshold) do
    a = Enum.with_index(inputs)
      |> Enum.map(fn({x, i}) -> x * Enum.at(weights, i) end)
      |> List.foldr(0, fn(acc, x) -> x + acc end)
    cond do
        a > threshold -> true
        true -> false
    end
  end

  @doc """

  """
  def perturb(%Zaxxon{threshold_matrix: tm, weights_matrix: wm} = zax, intensity) do
  end


end
