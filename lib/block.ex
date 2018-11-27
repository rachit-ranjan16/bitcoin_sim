defmodule Block do
  defstruct timestamp: nil,
            # data: "default",
            transactions: nil,
            prevBlockHash: "default",
            hash: nil,
            nonce: nil

  # def set_hash(%Block{timestamp: timestamp, data: data, prevBlockHash: prevBlockHash}) do
  #   :crypto.hash(:sha256, Kernel.to_string(timestamp) <> ";" <> data <> ";" <> prevBlockHash)
  #   |> Base.encode16()
  #   |> String.downcase()
  # end

  def create_block(transactions, prevBlockHash) do
    b = %Block{
      transactions: transactions,
      timestamp: :os.system_time(:seconds),
      prevBlockHash: prevBlockHash,
      nonce: 0
    }

    pw = ProofOfWork.new_pow(b, %ProofOfWork{})
    nonce_hash = ProofOfWork.run(pw, b.nonce)

    %{
      b
      | nonce: elem(nonce_hash, 0),
        hash:
          elem(nonce_hash, 1)
          |> Base.encode16()
          |> String.downcase()
    }
  end
end
