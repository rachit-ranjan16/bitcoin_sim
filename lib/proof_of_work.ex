defmodule ProofOfWork do
  use Bitwise
  @target_bits 6
  # TODO Can be removed. Check Later 
  @upper_limit 1 <<< (256 - @target_bits + 1)
  defstruct block: nil, target: nil

  def new_pow(%Block{} = b, %ProofOfWork{} = pw) do
    %{pw | block: b, target: 1 <<< (256 - @target_bits)}
  end

  def prepare_data(%ProofOfWork{} = pw, nonce) do
    pw.block.prevBlockHash <>
      pw.block.data <>
      Integer.to_string(pw.block.timestamp, 16) <>
      Integer.to_string(@target_bits, 16) <> Integer.to_string(nonce, 16)
  end

  # def run(%ProofOfWork{} = pw, nonce, hash) when nonce == @upper_limit do
  #     {nonce, hash} 
  # end 

  # when nonce < @upper_limit 
  def run(%ProofOfWork{} = pw, nonce) do
    # prevBlockHash=#{pw.block.prevBlockHash}")
    IO.puts("Mining Block containing Data=#{pw.block.data} Nonce=#{nonce}")
    data = ProofOfWork.prepare_data(pw, nonce)
    hash = :crypto.hash(:sha256, data)

    # IO.puts(
    #   "hash=#{Kernel.inspect(hash)} target=#{Kernel.inspect(<<pw.target::size(256)>>)} nonce=#{
    #     nonce
    #   }"
    # )

    if hash < <<pw.target::size(256)>> do
      {nonce, hash}
    else
      ProofOfWork.run(pw, nonce + 1)
    end
  end
end
