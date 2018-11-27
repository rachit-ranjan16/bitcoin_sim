defmodule BlockChain do
  @genesisCoinbaseData "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks"
  defstruct tail: nil

  def add_block(%BlockChain{tail: tail} = bc, transactions) do
    b = Block.create_block(transactions, elem(Enum.at(:ets.lookup(:bc_cache, tail), 0), 1).hash)
    :ets.insert(:bc_cache, {b.hash, b})
    :ets.insert(:bc_cache, {:tail, b.hash})
    %{bc | tail: b.hash}
  end

  def print_blocks(%BlockChain{tail: tail} = bc, continue)
      when continue === true do
    b = elem(Enum.at(:ets.lookup(:bc_cache, tail), 0), 1)
    b |> Kernel.inspect() |> IO.puts()

    print_blocks(
      %BlockChain{tail: b.prevBlockHash},
      elem(Enum.at(:ets.lookup(:bc_cache, b.prevBlockHash), 0), 1).prevBlockHash != "Genesis"
    )
  end

  def print_blocks(%BlockChain{tail: tail} = bc, continue)
      when continue === false do
    elem(Enum.at(:ets.lookup(:bc_cache, tail), 0), 1) |> Kernel.inspect() |> IO.puts()
  end

  def new_block_chain(%BlockChain{tail: _} = bc, address) do
    if :ets.lookup(:bc_cache, :tail) === [] do
      # TODO Define the coinbase transaction 
      genesis =
        Block.create_block(
          [Transaction.new_coinbase_tx(%Transaction{}, address, @genesisCoinbaseData)],
          "Genesis"
        )

      :ets.insert(:bc_cache, {genesis.hash, genesis})
      :ets.insert(:bc_cache, {:tail, genesis.hash})
      tail = genesis.hash
      %{bc | tail: tail}
    else
      tail = elem(Enum.at(:ets.lookup(:bc_cache, :tail), 0), 1)
      %{bc | tail: tail}
    end
  end

  def find_unspent_transactions(%BlockChain{tail: tail} = bc, address) do
    st = %{}
    unspentTXs = [] 
    Enum.each bc.block
  end

  def main(args) do
    :ets.new(:bc_cache, [:set, :public, :named_table])
    bc = BlockChain.new_block_chain(%BlockChain{}, "Genesis")

    bc =
      BlockChain.add_block(bc, [
        Transaction.new_coinbase_tx(%Transaction{}, "Rachit", @genesisCoinbaseData)
      ])

    bc =
      BlockChain.add_block(bc, [
        Transaction.new_coinbase_tx(%Transaction{}, "Ranjan", @genesisCoinbaseData)
      ])

    bc =
      BlockChain.add_block(bc, [
        Transaction.new_coinbase_tx(%Transaction{}, "Aditya", @genesisCoinbaseData)
      ])

    bc =
      BlockChain.add_block(bc, [
        Transaction.new_coinbase_tx(%Transaction{}, "Vashist", @genesisCoinbaseData)
      ])

    BlockChain.print_blocks(bc, true)
  end
end
