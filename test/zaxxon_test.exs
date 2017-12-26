defmodule ZaxxonTest do
  use ExUnit.Case
  doctest Zaxxon

  test "add and remove pids" do
    :flush
    a = spawn Zaxxon.neuron(%{ c: 0, t: 1, next: [self()]  })
    b = spawn Zaxxon.neuron(%{ c: 0, t: 1, next: [self()]  })
    send(a, {:add_pid, b})
    send(a, {:del_pid, self()})
    send(a, {:sig, 1})
    assert Process.info(self(), :messages) == {:messages, []}
  end

end
