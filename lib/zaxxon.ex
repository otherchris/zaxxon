defmodule Zaxxon do
  @moduledoc """
  Documentation for Zaxxon.

  """

  @decay 0.05
  @doc """
  Neuron loop

  ## Examples

    iex> a = spawn Zaxxon.neuron(%{ c: 0, t: 1, next: [self()]  })
    iex> send(a, {:sig, 0})
    iex> Process.sleep(1)
    iex> Process.info(self(), :messages)
    {:messages, []}

    iex> a = spawn Zaxxon.neuron(%{ c: 0, t: 1, next: [self()]  })
    iex> send(a, {:sig, 1})
    iex> Process.sleep(1)
    iex> Process.info(self(), :messages)
    {:messages, [{:sig, 1}]}

    iex> a = spawn Zaxxon.neuron(%{ c: 0, t: 1, next: [self()]  })
    iex> send(a, {:sig, 0.1})
    iex> Process.sleep(1)
    iex> Process.info(self(), :messages)
    {:messages, []}

    iex> a = spawn Zaxxon.neuron(%{ c: 0, t: 1, next: [self()]  })
    iex> send(a, {:sig, 0.1})
    iex> send(a, {:sig, 0.9})
    iex> Process.sleep(1)
    iex> Process.info(self(), :messages)
    {:messages, []}

    iex> a = spawn Zaxxon.neuron(%{ c: 0, t: 1, next: [self()]  })
    iex> send(a, {:sig, 0.1})
    iex> send(a, {:sig, 0.95})
    iex> Process.sleep(1)
    iex> Process.info(self(), :messages)
    {:messages, [{:sig, 1}]}

  """
  def neuron(a) do
    fn -> loop(a) end
  end

  def loop(a = %{ c: c, t: t, next: pid_list }) when is_list(pid_list) do
    c_new = receive do
      {:sig, sig} -> c + sig
      _ -> c
    end
    cond do
      c_new >= t ->
        Enum.each(pid_list, fn(x) ->
          send(x, {:sig, t})
          Process.sleep(1)
          loop(%{ c: 0, t: t, next: pid_list})
        end)
      c_new > 0 ->
        loop(%{c: c_new - (c_new * @decay), t: t, next: pid_list})
      true ->
        loop(a)
    end
  end
end
