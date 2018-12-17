defmodule BlockChainIterator do
  defstruct curr: nil, block: nil

  def new_iterator(%BlockChainIterator{} = bci, %BlockChain{tail: tail} = bc, cache_id) do
    # Cache Entry=#{:ets.lookup(:bc_cache, bc.tail).prevBlockHash}" 
    # IO.puts("RACHITLOG=#{Kernel.inspect(bc.tail)}")
    %{bci | curr: bc.tail, block: elem(Enum.at(:ets.lookup(cache_id, bc.tail), 0), 1)}
  end

  def next(%BlockChainIterator{} = bci, cache_id) do
    b = elem(Enum.at(:ets.lookup(cache_id, bci.curr), 0), 1)
    # IO.puts("#{Kernel.inspect(b.prevBlockHash)}")

    if b.prevBlockHash != "Genesis" do
      %{
        bci
        | curr: b.prevBlockHash,
          block: elem(Enum.at(:ets.lookup(cache_id, b.prevBlockHash), 0), 1)
      }
    else
      %{bci | curr: b.prevBlockHash, block: nil}
    end
  end
end
