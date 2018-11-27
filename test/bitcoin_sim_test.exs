defmodule BitcoinSimTest do
  use ExUnit.Case
  doctest BitcoinSim

  test "create and test blockchain" do
    # Initialize Blockchain with Genesis 
    # Use Proof of work to add block 
    # Assert whether the created blockchain in valid 
    :ets.new(:bc_cache, [:set, :public, :named_table])
    bc = BlockChain.new_block_chain(%BlockChain{})
    bc = BlockChain.add_block(bc, "Rachit")
    bc = BlockChain.add_block(bc, "DoodlyWoodle")
    bc = BlockChain.add_block(bc, "Aditya")
    bc = BlockChain.add_block(bc, "MoodyWoody")

    # Assert data  and links in block chain 
    assert elem(Enum.at(:ets.lookup(:bc_cache, bc.tail), 0), 1).data === "MoodyWoody"

    prevHash = elem(Enum.at(:ets.lookup(:bc_cache, bc.tail), 0), 1).prevBlockHash
    cur = elem(Enum.at(:ets.lookup(:bc_cache, prevHash), 0), 1)
    assert cur.data === "Aditya"
    assert cur.hash === prevHash

    prevHash = cur.prevBlockHash
    cur = elem(Enum.at(:ets.lookup(:bc_cache, prevHash), 0), 1)
    assert cur.data === "DoodlyWoodle"
    assert cur.hash === prevHash

    prevHash = cur.prevBlockHash
    cur = elem(Enum.at(:ets.lookup(:bc_cache, prevHash), 0), 1)
    assert cur.data === "Rachit"
    assert cur.hash === prevHash

    prevHash = cur.prevBlockHash
    cur = elem(Enum.at(:ets.lookup(:bc_cache, prevHash), 0), 1)
    assert cur.data === "Genesis"
    assert cur.hash === prevHash
    assert cur.prevBlockHash === "None"
  end
end
