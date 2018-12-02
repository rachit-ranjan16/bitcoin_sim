defmodule BlockChainIterator do
  defstruct curr: nil, block: nil

  def new_iterator(%BlockChainIterator{} = bci, %BlockChain{tail: tail} = bc) do
    # Cache Entry=#{:ets.lookup(:bc_cache, bc.tail).prevBlockHash}" 
    # IO.puts("RACHITLOG=#{Kernel.inspect(bc.tail)}")
    %{bci | curr: bc.tail, block: elem(Enum.at(:ets.lookup(:bc_cache, bc.tail), 0), 1)}
  end

  def next(%BlockChainIterator{} = bci) do
    b = elem(Enum.at(:ets.lookup(:bc_cache, bci.curr), 0), 1)
    # IO.puts("#{Kernel.inspect(b.prevBlockHash)}")

    if b.prevBlockHash != "Genesis" do
      %{
        bci
        | curr: b.prevBlockHash,
          block: elem(Enum.at(:ets.lookup(:bc_cache, b.prevBlockHash), 0), 1)
      }
    else
      %{bci | curr: b.prevBlockHash, block: nil}
    end
  end
end
