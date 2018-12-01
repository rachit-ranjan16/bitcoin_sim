defmodule InputTransaction do
  # tx_id Previous Transaction Block's ID 
  # v_out Index into Previous Transaction's out_tx
  # script_sig Signs a Transaction  
  defstruct tx_id: nil, v_out: nil, script_sig: nil

  def can_unlock_output_with(%InputTransaction{} = intx, unlocking_data) do
    IO.puts("Ip Transaction Sig=#{intx.scriptSig}, Unlocking Data=#{unlocking_data}")
    intx.script_sig === unlocking_data
  end
end
