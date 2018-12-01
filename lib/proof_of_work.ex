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
    # IO.puts "Logging"    
    # hash_transactions(pw.block.transactions, 0, length(pw.block.transactions) , <<0>>) |>Kernel.inspect |> IO.puts
    # pw.block.data <>
    # :crypto.hash(:sha256,:crypto.strong_rand_bytes(8)) <>
    pw.block.prevBlockHash <>
      :crypto.hash(
        :sha256,
        hash_transactions(pw.block.transactions, 0, length(pw.block.transactions), <<0>>)
      ) <>
      Integer.to_string(pw.block.timestamp, 16) <>
      Integer.to_string(@target_bits, 16) <> Integer.to_string(nonce, 16)
  end

  # def hash_transactions([%Transaction{}] = trans) do
  #   hash = <<0>>
  #   Enum.each trans, fn t ->
  #             hash = hash <> Map.get(t, :ID)
  #   end 
  #   hash |>Kernel.inspect |> IO.puts
  # end
  def hash_transactions(transactions, i, limit, hash) when i < limit do
    Map.get(Enum.at(transactions, i), :ID) <> hash_transactions(transactions, i + 1, limit, hash)
  end

  def hash_transactions(transactions, i, limit, hash) when i === limit do
    hash
  end

  # def hash_transactions(transactions) do
  #   Map.get(Enum.at(transactions,0), :ID)  |> Kernel.inspect |> IO.puts
  # end

  # def run(%ProofOfWork{} = pw, nonce, hash) when nonce == @upper_limit do
  #     {nonce, hash} 
  # end 

  def run(%ProofOfWork{} = pw, nonce) do
    # IO.puts(
    #   "Mining Block containing Transactions=#{Kernel.inspect(pw.block.transactions)} Nonce=#{
    #     nonce
    #   }"
    # )

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

  def check(hash, i, limit) when i < limit do
    <<1>> <> check(hash, i + 1, limit)
  end

  def check(hash, i, limit) when i === limit do
    hash
  end
end
