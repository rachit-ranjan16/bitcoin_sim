defmodule BitcoinSimTest do
  use ExUnit.Case
  doctest BlockChain

  # IO.puts("Rachit=#{rachit |> Base.encode16()} Aditya=#{aditya |> Base.encode16()}")

  setup do
    :ets.new(:bc_cache, [:set, :public, :named_table])
    bc = BlockChain.new_block_chain(%BlockChain{}, "Ranjan")
    wallets = %{}
    wallets = Map.put(wallets, "Rachit", Wallet.new_wallet(%Wallet{}))
    wallets = Map.put(wallets, "Aditya", Wallet.new_wallet(%Wallet{}))
    rachit = Map.get(Map.get(wallets, "Rachit"), :public_key)
    aditya = Map.get(Map.get(wallets, "Aditya"), :public_key)
    {:ok, %{:rachit => rachit, :aditya => aditya, :bc => bc}}
  end

  test "Aditya buy 7 coins", state do
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:aditya], state[:aditya], 7))
    assert BlockChain.get_balance(state[:bc], state[:aditya]) === 7
  end

  test "Rachit buy 10 coins", state do
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:rachit], state[:rachit], 10))
    assert BlockChain.get_balance(state[:bc], state[:rachit]) === 10
  end

  test "Rachit sends Aditya 6 coins", state do
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:rachit], state[:rachit], 10))
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:aditya], state[:aditya], 7))
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:rachit], state[:aditya], 6))
    assert BlockChain.get_balance(state[:bc], state[:rachit]) === 4
    assert BlockChain.get_balance(state[:bc], state[:aditya]) === 13
  end

  test "Aditya sends Rachit 2 coins", state do
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:rachit], state[:rachit], 10))
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:aditya], state[:aditya], 7))
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:rachit], state[:aditya], 6))
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:aditya], state[:rachit], 2))
    assert BlockChain.get_balance(state[:bc], state[:rachit]) === 6
    assert BlockChain.get_balance(state[:bc], state[:aditya]) === 11
  end

  test "Rachit sends Aditya 3 coins", state do
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:rachit], state[:rachit], 10))
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:aditya], state[:aditya], 7))
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:rachit], state[:aditya], 6))
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:aditya], state[:rachit], 2))
    state = Map.put(state, :bc, BlockChain.send(state[:bc], state[:rachit], state[:aditya], 3))
    assert BlockChain.get_balance(state[:bc], state[:rachit]) === 3
    assert BlockChain.get_balance(state[:bc], state[:aditya]) === 14
  end
end
