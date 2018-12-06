defmodule InputTransaction do
  # tx_id Previous Transaction Block's ID 
  # v_out Index into Previous Transaction's out_tx
  # script_sig Signs a Transaction  
  defstruct tx_id: nil, v_out: nil, signature: nil, public_key: nil

  # def uses_key(intx, public)
  def can_unlock_output_with(intx, public_key) do
    # :crypto.hash(:ripemd160, :crypto.hash(:sha256, intx.public_key)) === pub_key_hash
    IO.puts(
      "IntX PublicKey=#{get_printable(intx.public_key)} IncomingPublicKey=#{
        get_printable(public_key)
      }"
    )

    IO.puts("INTX Unlock=#{intx.public_key === public_key}")
    intx.public_key === public_key
  end

  # def can_unlock_output_with(intx, unlocking_data) do
  #   # IO.puts("Ip Transaction Sig=#{intx.script_sig}, Unlocking Data=#{unlocking_data}")
  #   intx.script_sig === unlocking_data
  # end

  def get_printable(something) do
    # 
    Kernel.inspect(something) |> Base.encode64()
  end
end
