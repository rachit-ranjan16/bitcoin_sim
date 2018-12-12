defmodule BlockChain do
  @genesisCoinbaseData "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks"
  defstruct tail: nil

  def verify_transactions(transactions, i, limit, public_key) when i === limit do
    true
  end

  def verify_transactions(transactions, i, limit, public_key) when i < limit do
    Transaction.verify(Enum.at(transactions, i), public_key) and
      verify_transactions(transactions, i + 1, limit, public_key)
  end

  def add_genesis_block(bc, genBlock, cache_id) do
    :ets.insert(cache_id, {genBlock.hash, genBlock})
    :ets.insert(cache_id, {:tail, genBlock.hash})
    %{bc | tail: genBlock.hash}
  end

  # def 
  def add_block(bc, transactions, public_key, cache_id) do
    bc =
      if verify_transactions(transactions, 0, length(transactions), public_key) do
        b = Block.create_block(transactions, elem(Enum.at(:ets.lookup(cache_id, :tail), 0), 1))
        :ets.insert(cache_id, {b.hash, b})
        :ets.insert(cache_id, {:tail, b.hash})

        # IO.puts("Added new block with hash=#{b.hash} to Blockchain")
        # bc.tail = b.hash
        %{bc | tail: b.hash}
      else
        IO.puts("Couldn't Verify Transaction. Not Adding to the block")
        bc
      end

    # b = Block.create_block(transactions, elem(Enum.at(:ets.lookup(:bc_cache, :tail), 0), 1))

    # :ets.insert(:bc_cache, {b.hash, b})
    # :ets.insert(:bc_cache, {:tail, b.hash})
    # IO.puts("Added new block with hash=#{b.hash} to Blockchain")
    # # bc.tail = b.hash
    # %{bc | tail: b.hash}
  end

  def print_blocks(%BlockChain{tail: tail} = bc, continue, cache_id)
      when continue === false do
    # elem(Enum.at(:ets.lookup(:bc_cache, tail), 0), 1) |> Kernel.inspect() |> IO.puts()
  end

  def print_blocks(%BlockChain{tail: tail} = bc, continue, cache_id)
      when continue === true do
    b = elem(Enum.at(:ets.lookup(cache_id, tail), 0), 1)
    b |> Kernel.inspect() |> IO.puts()

    print_blocks(
      %BlockChain{tail: b.prevBlockHash},
      # elem(Enum.at(:ets.lookup(:bc_cache, b.prevBlockHash), 0), 1).prevBlockHash != "Genesis"
      b.prevBlockHash != "Genesis",
      cache_id
    )
  end

  def new_block_chain(%BlockChain{tail: _} = bc, address) do
    if :ets.lookup(:bc_cache, :tail) === [] do
      IO.puts("Initializing Blockchain with Coinbase Transaction")

      genesis =
        Block.create_block(
          [Transaction.new_coinbase_tx(%Transaction{}, address, @genesisCoinbaseData)],
          "Genesis"
        )

      :ets.insert(:bc_cache, {genesis.hash, genesis})
      :ets.insert(:bc_cache, {:tail, genesis.hash})
      tail = genesis.hash
      %{bc | tail: tail}
    else
      tail = elem(Enum.at(:ets.lookup(:bc_cache, :tail), 0), 1)
      %{bc | tail: tail}
    end
  end

  def unspent_trans_helper(
        bci,
        st,
        unspentTXs,
        address,
        continue,
        cache_id
      )
      when continue === false do
    unspentTXs
  end

  def unspent_trans_helper(bci, st, unspentTXs, address, continue, cache_id)
      when continue === true do
    st_unspentTXs =
      transaction_walker(bci, st, 0, length(bci.block.transactions), unspentTXs, address)

    bci_next = BlockChainIterator.next(bci, cache_id)
    # IO.puts("Unspent Tx outside loop=#{Kernel.inspect(elem(st_unspentTXs, 1))}")

    unspent_trans_helper(
      bci_next,
      elem(st_unspentTXs, 0),
      elem(st_unspentTXs, 1),
      address,
      bci_next.block != nil,
      cache_id
    )
  end

  def find_unspent_transactions(%BlockChain{tail: tail} = bc, address, cache_id) do
    unspent_trans_helper(
      BlockChainIterator.new_iterator(%BlockChainIterator{}, bc, cache_id),
      %{},
      [],
      address,
      true,
      cache_id
    )
  end

  def out_transaction_walker(tx, st, i, limit, unspentTXs, address) when i === limit do
    unspentTXs
  end

  def out_transaction_walker(tx, st, i, limit, unspentTXs, address) when i < limit do
    unspentTXs =
      unspentTXs ++
        if check_referenced_outputs(tx, st, i) === true do
          out_tx_i = Enum.at(tx.out_tx, i)

          # IO.puts(
          #   "PublicKey=#{address |> Kernel.inspect() |> Base.encode64()}\n PublicKeyHash=#{
          #     :crypto.hash(:ripemd160, :crypto.hash(:sha256, address))
          #     |> Kernel.inspect()
          #     |> Base.encode64()
          #   }"
          # )

          if OutputTransaction.can_be_unlocked_with(out_tx_i, address) do
            [tx]
          else
            []
          end
        else
          []
        end

    out_transaction_walker(tx, st, i + 1, limit, unspentTXs, address)
  end

  def transaction_walker(bci, st, i, limit, unspentTXs, address) when i === limit do
    {st, unspentTXs}
  end

  def transaction_walker(bci, st, i, limit, unspentTXs, address) when i < limit do
    tx = Enum.at(bci.block.transactions, i)
    unspentTXs = out_transaction_walker(tx, st, 0, length(tx.out_tx), unspentTXs, address)

    if Transaction.is_coinbase(tx) === false do
      Enum.each(tx.in_tx, fn intx ->
        if InputTransaction.can_unlock_output_with(intx, address) do
          st =
            if Map.get(st, intx.tx_id) != nil do
              Map.put(st, intx.tx_id, Map.get(st, intx.tx_id) ++ [intx.v_out])
            else
              Map.put(st, intx.tx_id, [intx.v_out])
            end
        end
      end)
    end

    transaction_walker(bci, st, i + 1, limit, unspentTXs, address)
  end

  def check_referenced_outputs(tx, st, i) do
    if Map.get(st, Map.get(tx, :ID)) != nil do
      for k <- 0..(length(Map.get(st, Map.get(tx, :ID))) - 1) do
        if Enum.at(Map.get(st, Map.get(tx, :ID)), k) === i do
          false
        end
      end
    end

    true
  end

  def find_utxo_helper(out_tx, utxos, address, i, limit) when i < limit do
    # IO.puts(
    #   "PublicKey=#{address |> Kernel.inspect() |> Base.encode64()}\n PublicKeyHash=#{
    #     :crypto.hash(:ripemd160, :crypto.hash(:sha256, address))
    #     |> Kernel.inspect()
    #     |> Base.encode64()
    #   }"
    # )

    utxos =
      utxos ++
        if OutputTransaction.can_be_unlocked_with(Enum.at(out_tx, i), address) do
          [Enum.at(out_tx, i)]
        else
          []
        end

    find_utxo_helper(out_tx, utxos, address, i + 1, limit)
  end

  def find_utxo_helper(out_tx, utxos, address, i, limit) when i === limit do
    utxos
  end

  def unspent_transaction_walker(list_txs, utxo, i, limit, bc, address) when i === limit do
    utxo
  end

  def unspent_transaction_walker(list_txs, utxo, i, limit, bc, address) when i < limit do
    tx = Enum.at(list_txs, i)

    utxo =
      utxo ++ find_utxo_helper(Map.get(tx, :out_tx), [], address, 0, length(Map.get(tx, :out_tx)))

    unspent_transaction_walker(list_txs, utxo, i + 1, limit, bc, address)
  end

  def find_utxo(bc, address, cache_id) do
    list_txs = find_unspent_transactions(bc, address, cache_id)
    utxo = unspent_transaction_walker(list_txs, [], 0, length(list_txs), bc, address)
    utxo
  end

  def out_transaction_walker_spendable(tx, accumulated, amount, unspentOuts, i, limit, address)
      when i === limit do
    {accumulated, unspentOuts}
  end

  def out_transaction_walker_spendable(tx, accumulated, amount, unspentOuts, i, limit, address)
      when i < limit and accumulated >= amount do
    {accumulated, unspentOuts}
  end

  def out_transaction_walker_spendable(tx, accumulated, amount, unspentOuts, i, limit, address)
      when i < limit and accumulated < amount do
    out = Enum.at(tx.out_tx, i)

    # IO.puts(
    #   "PublicKey=#{address |> Kernel.inspect() |> Base.encode64()} \nPublicKeyHash=#{
    #     :crypto.hash(:ripemd160, :crypto.hash(:sha256, address))
    #     |> Kernel.inspect()
    #     |> Base.encode64()
    #   }"
    # )

    accumulated =
      accumulated +
        if OutputTransaction.can_be_unlocked_with(out, address) do
          out.value
        else
          0
        end

    unspentOuts =
      if OutputTransaction.can_be_unlocked_with(out, address) do
        # IO.puts("\n\n\nUnspentOuts=#{Kernel.inspect(unspentOuts)}\n\n\n")

        if Map.get(unspentOuts, Map.get(tx, :ID)) != nil do
          Map.put(unspentOuts, Map.get(tx, :ID), Map.get(unspentOuts, Map.get(tx, :ID)) ++ [i])
        else
          Map.put(unspentOuts, Map.get(tx, :ID), [i])
        end
      else
        unspentOuts
      end

    out_transaction_walker_spendable(tx, accumulated, amount, unspentOuts, i + 1, limit, address)
  end

  def find_spendable_output_helper(utxos, accumulated, amount, unspentOuts, i, limit, address)
      when i === limit do
    {accumulated, unspentOuts}
  end

  def find_spendable_output_helper(utxos, accumulated, amount, unspentOuts, i, limit, address)
      when i < limit do
    tx = Enum.at(utxos, i)

    accumulated_unspentOuts =
      out_transaction_walker_spendable(
        tx,
        accumulated,
        amount,
        unspentOuts,
        0,
        length(tx.out_tx),
        address
      )

    find_spendable_output_helper(
      utxos,
      elem(accumulated_unspentOuts, 0),
      amount,
      elem(accumulated_unspentOuts, 1),
      i + 1,
      limit,
      address
    )
  end

  def find_spendable_output(bc, address, amount, cache_id) do
    utxos = BlockChain.find_unspent_transactions(bc, address, cache_id)
    find_spendable_output_helper(utxos, 0, amount, %{}, 0, length(utxos), address)
  end

  def get_balance_helper(utxos, i, limit, balance, address) when i === limit do
    balance
  end

  def get_balance_helper(utxos, i, limit, balance, address) when i < limit do
    balance = balance + Enum.at(utxos, i).value
    get_balance_helper(utxos, i + 1, limit, balance, address)
  end

  def get_balance(bc, address, cache_id) do
    utxos = BlockChain.find_utxo(bc, address, cache_id)
    # IO.puts("\n\n\nUTXOs=#{Kernel.inspect(utxos)}\n\n\n")
    get_balance_helper(utxos, 0, length(utxos), 0, address)
  end

  def input_appender(outs, i, limit, txID, from) when i === limit do
    []
  end

  def input_appender(outs, i, limit, txID, from) when i < limit do
    [%InputTransaction{tx_id: txID, v_out: Enum.at(outs, i), public_key: from}] ++
      input_appender(outs, i + 1, limit, txID, from)
  end

  def valid_outputs_walker(unspentOuts, i, limit, keys, from, inputs) when i === limit do
    inputs
  end

  def valid_outputs_walker(unspentOuts, i, limit, keys, from, inputs) when i < limit do
    outs = Map.get(unspentOuts, Enum.at(keys, i))
    inputs = inputs ++ input_appender(outs, 0, length(outs), Enum.at(keys, i), from)
  end

  def new_utxo_transaction(bc, from, to, amount, private_key, cache_id) do
    accumulated_unspentOuts = BlockChain.find_spendable_output(bc, from, amount, cache_id)
    # IO.puts("acc_unspent=#{Kernel.inspect(accumulated_unspentOuts)}")

    if elem(accumulated_unspentOuts, 0) >= amount do
      keys = Map.keys(elem(accumulated_unspentOuts, 1))

      inputs =
        valid_outputs_walker(elem(accumulated_unspentOuts, 1), 0, length(keys), keys, from, [])

      # IO.puts(
      #   "PublicKey=#{to |> Kernel.inspect() |> Base.encode64()}\nPublicKeyHash=#{
      #     :crypto.hash(:ripemd160, :crypto.hash(:sha256, to))
      #     |> Kernel.inspect()
      #     |> Base.encode64()
      #   }"
      # )

      outputs =
        [
          %OutputTransaction{
            value: amount,
            public_key_hash: :crypto.hash(:ripemd160, :crypto.hash(:sha256, to))
            # public_key: to
          }
        ] ++
          if elem(accumulated_unspentOuts, 0) >= amount do
            # IO.puts("Trying to create output transaction")

            [
              %OutputTransaction{
                value: -1 * amount,
                public_key_hash: :crypto.hash(:ripemd160, :crypto.hash(:sha256, from))
                # public_key: from
              }
            ]
          else
            []
          end

      # IO.puts("input=#{Kernel.inspect(inputs)} output=#{Kernel.inspect(outputs)}")

      signed_tx =
        Transaction.sign(
          %Transaction{
            ID: :crypto.hash(:sha256, :crypto.strong_rand_bytes(5)),
            in_tx: inputs,
            out_tx: outputs
          },
          private_key
        )

      # IO.puts("SignedTransaction=#{Kernel.inspect(signed_tx)}")
      signed_tx
    else
      IO.puts("ERROR Not enough funds")
      nil
    end
  end

  def send(bc, from, to, amount, private_key, public_key, cache_id) do
    new_utxo = new_utxo_transaction(bc, from, to, amount, private_key, cache_id)
    # IO.puts("Send: Trying to print UTXO")
    # IO.inspect(new_utxo)

    bc =
      if new_utxo != nil do
        # IO.puts("Printing new transaction from=#{from} to=#{to}")
        # IO.puts("Success")
        BlockChain.add_block(bc, [new_utxo], public_key, cache_id)
      else
        IO.puts("Not Enough Funds")
        bc
      end
  end

  def buy(bc, from, buyer, amount, private_key, public_key, cache_id) do
    bc = send(bc, from, buyer, amount, private_key, public_key, cache_id)
    IO.puts("#{cache_id} Bought #{amount} coins")
    bc
  end

  def main(args) do
    # :ets.new(:bc_cache, [:set, :public, :named_table])
    # wallets = %{}
    # wallets = Map.put(wallets, "Rachit", Wallet.new_wallet(%Wallet{}))
    # wallets = Map.put(wallets, "Aditya", Wallet.new_wallet(%Wallet{}))
    # wallets = Map.put(wallets, "KC", Wallet.new_wallet(%Wallet{}))
    # wallets = Map.put(wallets, "coinbase", Wallet.new_wallet(%Wallet{}))

    # rachit = Map.get(Map.get(wallets, "Rachit"), :public_key)
    # aditya = Map.get(Map.get(wallets, "Aditya"), :public_key)
    # kc = Map.get(Map.get(wallets, "KC"), :public_key)
    # coinbase = Map.get(Map.get(wallets, "coinbase"), :public_key)
    # bc = BlockChain.new_block_chain(%BlockChain{}, coinbase)

    # {public_key, private_key} =
    #   :crypto.generate_key(
    #     :ecdh,
    #     :secp256k1
    #   )

    # # IO.puts(
    # #   "Aditya PublicKey=#{aditya |> Kernel.inspect() |> Base.encode64()} PublicKeyHash=#{
    # #     :crypto.hash(:ripemd160, :crypto.hash(:sha256, aditya))
    # #     |> Kernel.inspect()
    # #     |> Base.encode64()
    # #   }"
    # # )

    # # IO.puts("Rachit=#{rachit |> Base.encode16()} Aditya=#{aditya |> Base.encode16()}")
    # bc = buy(bc, coinbase, aditya, 7, private_key, public_key)
    # # IO.puts("\n\n\n")
    # # print_blocks(bc, true)
    # # IO.puts("\n\n\n")
    # bc = buy(bc, coinbase, rachit, 10, private_key, public_key)
    # bc = buy(bc, coinbase, kc, 12, private_key, public_key)
    # # print_blocks(bc, true)
    # IO.puts("coinbase's Balance=#{get_balance(bc, coinbase)}")
    # IO.puts("Aditya's Balance=#{get_balance(bc, aditya)}")
    # IO.puts("Rachit's Balance=#{get_balance(bc, rachit)}")
    # IO.puts("KC's Balance=#{get_balance(bc, kc)}")
    # bc = send(bc, rachit, aditya, 15, private_key, public_key)
    # IO.puts("coinbase's Balance=#{get_balance(bc, coinbase)}")
    # IO.puts("Aditya's Balance=#{get_balance(bc, aditya)}")
    # IO.puts("Rachit's Balance=#{get_balance(bc, rachit)}")
    # IO.puts("KC's Balance=#{get_balance(bc, kc)}")
    # bc = send(bc, kc, aditya, 6, private_key, public_key)
    # IO.puts("coinbase's Balance=#{get_balance(bc, coinbase)}")
    # IO.puts("Aditya's Balance=#{get_balance(bc, aditya)}")
    # IO.puts("Rachit's Balance=#{get_balance(bc, rachit)}")
    # IO.puts("KC's Balance=#{get_balance(bc, kc)}")
    # bc = send(bc, aditya, rachit, 2, private_key, public_key)
    # IO.puts("coinbase's Balance=#{get_balance(bc, coinbase)}")
    # IO.puts("Aditya's Balance=#{get_balance(bc, aditya)}")
    # IO.puts("Rachit's Balance=#{get_balance(bc, rachit)}")
    # IO.puts("KC's Balance=#{get_balance(bc, kc)}")
    # bc = send(bc, aditya, kc, 2, private_key, public_key)
    # IO.puts("coinbase's Balance=#{get_balance(bc, coinbase)}")
    # IO.puts("Aditya's Balance=#{get_balance(bc, aditya)}")
    # IO.puts("Rachit's Balance=#{get_balance(bc, rachit)}")
    # IO.puts("KC's Balance=#{get_balance(bc, kc)}")
  end
end
