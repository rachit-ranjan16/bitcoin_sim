defmodule Transaction do
  @subsidy 100
  defstruct ID: nil, in_tx: nil, out_tx: nil

  def new_coinbase_tx(%Transaction{} = t, to, data) do
    tx_in = %InputTransaction{tx_id: "none", v_out: -1, public_key: to}

    tx_out = %OutputTransaction{
      value: @subsidy,
      public_key_hash: :crypto.hash(:ripemd160, :crypto.hash(:sha256, to))
    }

    t = %Transaction{ID: nil, in_tx: [tx_in], out_tx: [tx_out]}

    # %{t | ID: :crypto.hash(:sha256, Enum.at(t.in_tx,0).tx_id <> ";"<>  Enum.at(t.in_tx,0).v_out <> ";" <> Enum.at(t.in_tx,0).script_sig <> ";" <>  Enum.at(t.out_tx,0).value <> ";" <> Enum.at(t.out_tx,0).script_pub_key )}
    %{t | ID: :crypto.hash(:sha256, :crypto.strong_rand_bytes(5))}
  end

  def is_coinbase(%Transaction{ID: _, in_tx: in_tx, out_tx: _} = tx) do
    length(in_tx) === 1 and Enum.at(in_tx, 0).tx_id === "none" and Enum.at(in_tx, 0).v_out === -1
  end

  def input_transaction_appender(tx, i, limit, input_list) when i === limit do
    []
  end

  def input_transaction_appender(tx, i, limit, input_list) when i < limit do
    intx = Enum.at(tx, i).in_tx

    input_list ++
      [
        %InputTransaction{
          tx_id:
            Map.get(intx, :tx_id,
              v_out: Map.get(intx, :v_out),
              signature: Map.get(intx, :signature)
            )
        }
      ] ++ [input_transaction_appender(tx, i + 1, limit, input_list)]
  end

  def ouput_transaction_appender(tx, i, limit, output_list) when i === limit do
    []
  end

  def ouput_transaction_appender(tx, i, limit, output_list) when i < limit do
    outx = Enum.at(tx, i).out_tx

    output_list ++
      [
        %OutputTransaction{
          value: Map.get(outx, :value),
          public_key_hash: Map.get(outx, :public_key_hash)
        }
      ] ++ [input_transaction_appender(tx, i + 1, limit, output_list)]
  end

  def trimmed_copy(tx) do
    intx = input_transaction_appender(tx, 0, length(tx.in_tx), [])
    outx = ouput_transaction_appender(tx, 0, length(tx.out_tx), [])
    %Transaction{in_tx: intx, out_tx: outx}
  end

  def populate_copy(tx, prevTXs, tx_copy, i, limit) when i === limit do
    tx_copy
  end

  def populate_copy(tx, prevTXs, tx_copy, i, limit) when i < limit do
    prevTX = Map.get(prevTXs, Enum.at(Map.get(tx.in_tx, :tx_id)))
  end

  def verify(tx) do
    true
  end

  def verify(tx, prevTXs) do
    if Transaction.is_coinbase(tx) do
      true
    else
      tx_copy = trimmed_copy(tx)
      tx_copy = populate_copy(tx, prevTXs, tx_copy, 0, 1)
    end
  end
end
