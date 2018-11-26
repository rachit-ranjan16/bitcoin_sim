defmodule BlockChain do
  defstruct tail: nil

  def add_block(%BlockChain{tail: tail} = bc, data) do
    b = Block.create_block(data, elem(Enum.at(:ets.lookup(:bc_cache, tail), 0), 1).hash)
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
      elem(Enum.at(:ets.lookup(:bc_cache, b.prevBlockHash), 0), 1).data != "Genesis"
    )
  end

  def print_blocks(%BlockChain{tail: tail} = bc, continue)
      when continue === false do
    elem(Enum.at(:ets.lookup(:bc_cache, tail), 0), 1) |> Kernel.inspect() |> IO.puts()
  end

  def new_block_chain(%BlockChain{tail: _} = bc) do
    if :ets.lookup(:bc_cache, :tail) === [] do
      genesis = Block.create_block("Genesis", "None")
      :ets.insert(:bc_cache, {genesis.hash, genesis})
      :ets.insert(:bc_cache, {:tail, genesis.hash})
      tail = genesis.hash
      %{bc | tail: tail}
    else
      tail = elem(Enum.at(:ets.lookup(:bc_cache, :tail), 0), 1)
      %{bc | tail: tail}
    end
  end

  def main(args) do
    :ets.new(:bc_cache, [:set, :public, :named_table])
    bc = BlockChain.new_block_chain(%BlockChain{})
    bc = BlockChain.add_block(bc, "Rachit")
    bc = BlockChain.add_block(bc, "DoodlyWoodle")
    bc = BlockChain.add_block(bc, "Aditya")
    bc = BlockChain.add_block(bc, "MoodyWoody")
    BlockChain.print_blocks(bc, true)
  end
end
