defmodule Peer do
  @init_bal 10
  use GenServer

  def init([id, genesis, wallets, n]) do
    :ets.new(get_node_name(id), [:set, :public, :named_table])
    # wallets = Map.put(wallets, get_node_name(id), Wallet.new_wallet(%Wallet{}))
    bc = BlockChain.add_genesis_block(%BlockChain{}, genesis, get_node_name(id))
    # GenServer.cast(
    # BlockChain.print_blocks(bc, true, get_node_name(id))
    {:ok, [id, bc, wallets]}
  end

  def get_node_name(i) do
    id = i |> Integer.to_string() |> String.pad_leading(4, "0")
    ("Elixir.N" <> id) |> String.to_atom()
  end

  def handle_cast({:initial_buy}, [id, bc, wallets]) do
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

    # BlockChain.print_blocks(bc, true, get_node_name(id))
    {:noreply, [id, bc, wallets]}
  end

  def handle_cast({:get_balance}, [id, bc, wallets]) do
    IO.puts(
      "\n\n\nBalance of #{get_node_name(id)} = #{
        BlockChain.get_balance(
          bc,
          Map.get(Map.get(wallets, Peer.get_node_name(id)), :public_key),
          get_node_name(id)
        )
      }\n\n\n"
    )

    {:noreply, [id, bc, wallets]}
  end
end
