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

  def process_sig(a = %{ c: c_new, t: t, next: pid_list}) do
    cond do
      c_new >= t ->
        Enum.each(pid_list, fn(x) ->
          send(x, {:sig, t})
          loop(%{ c: 0, t: t, next: pid_list})
        end)
      c_new > 0 ->
        loop(%{c: c_new - (c_new * @decay), t: t, next: pid_list})
      true ->
        loop(a)
    end
  end

  @doc """
  Add a pid to the outputs of a neuron

  ## Examples

    iex> a = spawn Zaxxon.neuron(%{ c: 0, t: 1, next: [self()]  })
    iex> b = spawn Zaxxon.neuron(%{ c: 0, t: 1, next: [self()]  })
    iex> send(a, {:add_pid, b})
    iex> send(a, {:sig, 1})
    iex> send(b, {:sig, 1})
    iex> Process.sleep(1)
    iex> Process.info(self(), :messages)
    {:messages, [{:sig, 1}, {:sig, 1}]}

  """
  def add_pid(pid, a = %{ c: c, t: t, next: pid_list}) do
    loop(%{c: c, t: t, next: pid_list ++ [pid]})
  end

  @doc """
  Remove a pid from the outputs of a neuron

  ## Examples

    iex> a = spawn Zaxxon.neuron(%{ c: 0, t: 1, next: [self()]  })
    iex> b = spawn Zaxxon.neuron(%{ c: 0, t: 1, next: [self()]  })
    iex> send(a, {:del_pid, self()})
    iex> send(a, {:sig, 1})
    iex> Process.info(self(), :messages)
    {:messages, []}

  """
  def del_pid(pid, a = %{ c: c, t: t, next: pid_list}) do
    loop(%{c: c, t: t, next: List.delete(pid_list, pid)})
  end

  @doc """
  Report the state of a neuron

  ## Examples

    iex> a = spawn Zaxxon.neuron(%{ c: 0, t: 1, next: [self()]  })
    iex> send(a, :report)
    iex> Process.sleep(1)
    iex> Process.info(self(), :messages)
    {:messages, [{:report, %{ c: 0, t: 1, next: [self()] }}]}
  """
  def report(a, pid_list) do
    Enum.each(pid_list, fn(x) -> send(x, {:report, a}) end)
    loop(a)
  end

  def loop(a = %{ c: c, t: t, next: pid_list }) when is_list(pid_list) do
    receive do
      :tick -> process_sig(a)
      :report -> report(a, pid_list)
      {:add_pid, pid} -> add_pid(pid, a)
      {:del_pid, pid} -> del_pid(pid, a)
      {:sig, sig} -> process_sig(%{c: c + sig, t: t, next: pid_list})
      _ -> loop(a)
    end
  end

  def play do
    n = %{t: 1, c: 0, next: []}
    ns = Enum.to_list(1..10) |> Enum.map(fn(x) -> spawn neuron(n) end)
    IO.inspect ns
  end

end
