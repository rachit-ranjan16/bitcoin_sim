defmodule BitcoinSimTest do
  use ExUnit.Case
  doctest BitcoinSim

  test "greets the world" do
    assert BitcoinSim.hello() == :world
  end
end
