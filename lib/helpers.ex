defmodule Zaxxon.Helpers do
  @moduledoc """
  Helpers for Zaxxoning
  """

  @doc """
  Normalize a number between 0 and 1

  ## Examples

      iex> Zaxxon.cap(1.2)
      1

      iex> Zaxxon.cap(-0.5)
      0

      iex> Zaxxon.cap(0.5)
      0.5
  """
  def cap(x) do
    cond do
      x > 1 -> 1
      x < 0 -> 0
      true -> x
    end
  end


end
