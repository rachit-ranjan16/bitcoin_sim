defmodule Peer do
  @init_bal 10
  use GenServer

  def init([id, genesis, wallets, n]) do
    :ets.new(get_node_name(id), [:set, :public, :named_table])
    bc = BlockChain.add_genesis_block(%BlockChain{}, genesis, get_node_name(id))
    {:ok, [id, bc, wallets, n]}
  end

  def get_node_name(i) do
    id = i |> Integer.to_string() |> String.pad_leading(4, "0")
    ("MINER.N" <> id) |> String.to_atom()
  end

  def get_node_name_string(i) do
    id = i |> Integer.to_string() |> String.pad_leading(4, "0")
    "MINER.N" <> id
  end

  def broadcast(id, n, block, public_key) do
    for i <- 1..n do
      if i != id do
        GenServer.cast(
          get_node_name(i),
          {:add_block, block, public_key}
        )
      end
    end
  end

  def handle_cast({:add_block, block, incoming_public_key}, [id, bc, _wallets, _n]) do
    bc =
      BlockChain.add_block(
        bc,
        Map.get(block, :transactions),
        incoming_public_key,
        get_node_name(id)
      )

    {:noreply, [id, bc, _wallets, _n]}
  end

  def handle_cast({:initial_buy}, [id, bc, wallets, n]) do
    coinbase = Map.get(Map.get(wallets, :coinbase), :public_key)
    public_key = Map.get(Map.get(wallets, Peer.get_node_name(id)), :public_key)
    private_key = Map.get(Map.get(wallets, Peer.get_node_name(id)), :private_key)

    bc =
      BlockChain.buy(
        bc,
        coinbase,
        public_key,
        @init_bal,
        private_key,
        public_key,
        get_node_name(id)
      )

    broadcast(
      id,
      n,
      elem(Enum.at(:ets.lookup(get_node_name(id), Map.get(bc, :tail)), 0), 1),
      public_key
    )

    {:noreply, [id, bc, wallets, n]}
  end

  def handle_cast({:send, to, amount}, [id, bc, wallets, n]) do
    start_ts = :os.system_time(:milli_seconds)
    public_key = Map.get(Map.get(wallets, Peer.get_node_name(id)), :public_key)
    private_key = Map.get(Map.get(wallets, Peer.get_node_name(id)), :private_key)
    to_public_key = Map.get(Map.get(wallets, Peer.get_node_name(to)), :public_key)
    initial_tail = Map.get(bc, :tail)

    bc =
      BlockChain.send(
        bc,
        public_key,
        to_public_key,
        amount,
        private_key,
        public_key,
        get_node_name(id)
      )

    if Map.get(bc, :tail) != initial_tail do
      GenServer.cast(:bitcoin_sim, {:trans_time, :os.system_time(:milli_seconds) - start_ts})

      broadcast(
        id,
        n,
        elem(Enum.at(:ets.lookup(get_node_name(id), Map.get(bc, :tail)), 0), 1),
        public_key
      )
    end

    {:noreply, [id, bc, wallets, n]}
  end

  def handle_cast({:get_balance}, [id, bc, wallets, n]) do
    IO.puts(
      "Balance of #{get_node_name(id)} = #{
        BlockChain.get_balance(
          bc,
          Map.get(Map.get(wallets, Peer.get_node_name(id)), :public_key),
          get_node_name(id)
        )
      }"
    )

    {:noreply, [id, bc, wallets, n]}
  end

  def handle_call({:balance}, from, [id, bc, wallets, n]) do
    {:reply,
     BlockChain.get_balance(
       bc,
       Map.get(Map.get(wallets, Peer.get_node_name(id)), :public_key),
       get_node_name(id)
     ), [id, bc, wallets, n]}
  end
end
