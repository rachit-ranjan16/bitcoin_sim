defmodule Transaction do
  @subsidy 10
  defstruct ID: nil, in_tx: nil, out_tx: nil

  def new_coinbase_tx(%Transaction{} = t, to, data) do
    if data === "" do
      data = "Reward to #{to}"
    end

    tx_in = %InputTransaction{tx_id: "none", v_out: -1, public_key: data}
    tx_out = %OutputTransaction{value: @subsidy, public_key: to}
    t = %Transaction{ID: nil, in_tx: [tx_in], out_tx: [tx_out]}

    # %{t | ID: :crypto.hash(:sha256, Enum.at(t.in_tx,0).tx_id <> ";"<>  Enum.at(t.in_tx,0).v_out <> ";" <> Enum.at(t.in_tx,0).script_sig <> ";" <>  Enum.at(t.out_tx,0).value <> ";" <> Enum.at(t.out_tx,0).script_pub_key )}
    %{t | ID: :crypto.hash(:sha256, :crypto.strong_rand_bytes(5))}
  end

  def is_coinbase(%Transaction{ID: _, in_tx: in_tx, out_tx: _} = tx) do
    length(in_tx) === 1 and Enum.at(in_tx, 0).tx_id === "none" and Enum.at(in_tx, 0).v_out === -1
  end
end
