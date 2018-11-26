defmodule BlockChain do
  # TODO Remove this 
  defstruct blocks: nil

  def add_block(%BlockChain{blocks: blocks} = bc, data) when blocks != nil do
    %{bc | blocks: blocks ++ [Block.create_block(data, Enum.at(blocks, length(blocks) - 1).hash)]}
  end

  def add_block(%BlockChain{blocks: blocks} = bc, data) when blocks == nil do
    %{bc | blocks: [Block.create_block(data, "Genesis")]}
  end

  def main(args) do
    bc = BlockChain.add_block(%BlockChain{}, "Genesis")
    bc = BlockChain.add_block(bc, "Rachit")
    bc = BlockChain.add_block(bc, "DoodlyWoodle")
    bc = BlockChain.add_block(bc, "Aditya")
    bc = BlockChain.add_block(bc, "MoodyWoody")
    bc |> Kernel.inspect() |> IO.puts()
  end
end
