defmodule Transaction do
  @subsidy 10
  defstruct ID: nil, in_tx: nil, out_tx: nil

  def new_coinbase_tx(%Transaction{} = t, to, data) do
    if data === "" do
      data = "Reward to #{to}"
    end

    tx_in = %InputTransaction{tx_id: "none", v_out: -1, script_sig: data}
    tx_out = %OutputTransaction{value: @subsidy, script_pub_key: to}
    t = %Transaction{ID: nil, in_tx: [tx_in], out_tx: [tx_out]}

    # %{t | ID: :crypto.hash(:sha256, Enum.at(t.in_tx,0).tx_id <> ";"<>  Enum.at(t.in_tx,0).v_out <> ";" <> Enum.at(t.in_tx,0).script_sig <> ";" <>  Enum.at(t.out_tx,0).value <> ";" <> Enum.at(t.out_tx,0).script_pub_key )}
    %{t | ID: :crypto.hash(:sha256, :crypto.strong_rand_bytes(5))}
  end
end
