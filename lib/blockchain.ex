defmodule BlockChain do
  @genesisCoinbaseData "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks"
  defstruct tail: nil

  def add_block(%BlockChain{tail: tail} = bc, transactions) do
    b = Block.create_block(transactions, elem(Enum.at(:ets.lookup(:bc_cache, tail), 0), 1).hash)
    :ets.insert(:bc_cache, {b.hash, b})
    :ets.insert(:bc_cache, {:tail, b.hash})
    %{bc | tail: b.hash}
  end

  def print_blocks(%BlockChain{tail: tail} = bc, continue)
      when continue === true do
    b = elem(Enum.at(:ets.lookup(:bc_cache, tail), 0), 1)
    b |> Kernel.inspect() |> IO.puts()

    print_blocks(
      %BlockChain{tail: b.prevBlockHash},
      elem(Enum.at(:ets.lookup(:bc_cache, b.prevBlockHash), 0), 1).prevBlockHash != "Genesis"
    )
  end

  def print_blocks(%BlockChain{tail: tail} = bc, continue)
      when continue === false do
    elem(Enum.at(:ets.lookup(:bc_cache, tail), 0), 1) |> Kernel.inspect() |> IO.puts()
  end

  def new_block_chain(%BlockChain{tail: _} = bc, address) do
    if :ets.lookup(:bc_cache, :tail) === [] do
      # TODO Define the coinbase transaction 
      genesis =
        Block.create_block(
          [Transaction.new_coinbase_tx(%Transaction{}, address, @genesisCoinbaseData)],
          "Genesis"
        )

      # TODO Remove Log 
      # IO.puts("RACHITLOG Going in Cache=#{Kernel.inspect(genesis.hash)}")
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
        continue
      )
      when continue === false do
    # when bci.block.prevBlockHash === "Genesis" do
    IO.puts("End of Blockchain unspentTXs=#{Kernel.inspect(unspentTXs)}")
    unspentTXs
  end

  def unspent_trans_helper(bci, st, unspentTXs, address, continue)
      # when bci.block.prevBlockHash != "Genesis" do
      when continue === true do
    # bci.block.prevBlockHash |> Kernel.inspect() |> IO.puts()
    IO.puts("Unspent Transaction Helper")

    st_unspentTXs =
      transaction_walker(bci, st, 0, length(bci.block.transactions), unspentTXs, address)

    # utx = 
    # for i <- 0..(length(bci.block.transactions) - 1) do
    #   tx = Enum.at(bci.block.transactions, i)
    # IO.puts("Inside i loop limit=#{length(bci.block.transactions)}")
    # unspentTXs = out_transaction_walker(tx, st, 0, length(tx.out_tx), unspentTXs, address)
    IO.puts("Unspent Tx after recursion=#{Kernel.inspect(elem(st_unspentTXs, 1))}")
    # for j <- 0..(length(tx.out_tx) - 1) do
    #   IO.puts("Referenced Outputs=#{check_referenced_outputs(tx, st, i)}")

    #   if check_referenced_outputs(tx, st, i) === true do
    #     out_tx_j = Enum.at(tx.out_tx, j)
    #     # IO.puts("OutTx=#{Map.get(tx.out_tx, :script_pub_key)}") 
    #     if OutputTransaction.can_be_unlocked_with(out_tx_j, address) do
    #       unspentTXs = unspentTXs ++ [tx]
    #       IO.puts("Unspent Tx in loop=#{Kernel.inspect(unspentTXs)}")
    #       #  IO.puts "Unspect Transaction Helper"
    #     end
    #   end
    # end

    #   if Transaction.is_coinbase(tx) === false do
    #     Enum.each(tx.in_tx, fn intx ->
    #       if InputTransaction.can_unlock_output_with(intx, address) do
    #         Map.put(st, intx.tx_id, Map.get(st, intx.tx_id) ++ [intx.v_out])
    #       end
    #     end)
    #   end
    # end

    # IO.puts()
    bci_next = BlockChainIterator.next(bci)
    IO.puts("Unspent Tx outside loop=#{Kernel.inspect(elem(st_unspentTXs, 1))}")

    unspent_trans_helper(
      bci_next,
      elem(st_unspentTXs, 0),
      elem(st_unspentTXs, 1),
      address,
      bci_next.block != nil
    )
  end

  def find_unspent_transactions(%BlockChain{tail: tail} = bc, address) do
    unspent_trans_helper(
      BlockChainIterator.new_iterator(%BlockChainIterator{}, bc),
      %{},
      [],
      address,
      true
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
          Map.put(st, intx.tx_id, Map.get(st, intx.tx_id) ++ [intx.v_out])
        end
      end)
    end

    transaction_walker(bci, st, i + 1, limit, unspentTXs, address)
  end

  def check_referenced_outputs(tx, st, i) do
    IO.puts("Cache Lookup=#{Kernel.inspect(Map.get(st, Map.get(tx, :ID)))}")

    if Map.get(st, Map.get(tx, :ID)) != nil do
      IO.puts("k loop limit=#{length(Map.get(st, Map.get(tx, :ID)))}")

      for k <- 0..(length(Map.get(st, Map.get(tx, :ID))) - 1) do
        IO.puts("Inside k loop")

        if Enum.at(Map.get(st, Map.get(tx, :ID)), k) === i do
          false
        end
      end
    end

    true
  end

  def find_utxo_helper(out_tx, utxos, address, i, limit) when i < limit do
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
    IO.puts("UTXO output helper=#{Kernel.inspect(utxos)}")
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

  def find_utxo(%BlockChain{tail: tail} = bc, address) do
    list_txs = find_unspent_transactions(bc, address)
    utxo = unspent_transaction_walker(list_txs, [], 0, length(list_txs), bc, address)
    # Enum.each(find_unspent_transactions(bc, address), fn tx ->
    #   IO.puts("TX Length=#{length(Map.get(tx, :out_tx))}")

    #   utxo =
    #     utxo ++
    #       find_utxo_helper(Map.get(tx, :out_tx), [], address, 0, length(Map.get(tx, :out_tx)))
    # end)

    IO.puts("UTXO output outside Enum.each=#{Kernel.inspect(utxo)}")
    utxo
  end

  def find_spendable_output(bc, address, amount) do
  def get_balance_helper(utxos, i, limit, balance, address) when i === limit do
    balance
  end

  def get_balance_helper(utxos, i, limit, balance, address) when i < limit do
    balance = balance + Enum.at(utxos, i).value
    get_balance_helper(utxos, i + 1, limit, balance, address)
  end

  def get_balance(address) do
    bc = BlockChain.new_block_chain(%BlockChain{}, address)
    # IO.puts("UTXO output=#{Kernel.inspect(BlockChain.find_utxo(bc, address))}")
    utxos = BlockChain.find_utxo(bc, address)
    get_balance_helper(utxos, 0, length(utxos), 0, address)
    # Enum.each(BlockChain.find_utxo(bc, address), fn out ->
    #   balance = balance + out.value
    #   IO.puts("Balance=#{balance}")    end)
    # balance
  end

  def main(args) do
    :ets.new(:bc_cache, [:set, :public, :named_table])
    # bc = BlockChain.new_block_chain(%BlockChain{}, "Genesis")
    IO.puts("Balance=#{get_balance("Rachit")}")
    # bc =
    #   BlockChain.add_block(bc, [
    #     Transaction.new_coinbase_tx(%Transaction{}, "Rachit", @genesisCoinbaseData)
    #   ])

    # bc =
    #   BlockChain.add_block(bc, [
    #     Transaction.new_coinbase_tx(%Transaction{}, "Ranjan", @genesisCoinbaseData)
    #   ])

    # bc =
    #   BlockChain.add_block(bc, [
    #     Transaction.new_coinbase_tx(%Transaction{}, "Aditya", @genesisCoinbaseData)
    #   ])

    # bc =
    #   BlockChain.add_block(bc, [
    #     Transaction.new_coinbase_tx(%Transaction{}, "Vashist", @genesisCoinbaseData)
    #   ])

    # BlockChain.print_blocks(bc, true)
  end
end
