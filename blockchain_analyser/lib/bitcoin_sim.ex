defmodule BitcoinSim do
  use GenServer

  def populate_wallet(wallets, i, limit) when i > limit do
    wallets
  end

  def populate_wallet(wallets, i, limit) when i <= limit do
    wallets = Map.put(wallets, Peer.get_node_name(i), Wallet.new_wallet(%Wallet{}))
    populate_wallet(wallets, i + 1, limit)
  end

  def main(args) do
    numNodes = String.to_integer(Enum.at(args, 0))
    numPeers = String.to_integer(Enum.at(args, 1))
    wallets = populate_wallet(%{}, 1, numNodes)
    wallets = Map.put(wallets, :coinbase, Wallet.new_wallet(%Wallet{}))
    coinbase = Map.get(Map.get(wallets, :coinbase), :public_key)

    genesis =
      Block.create_block(
        [Transaction.new_coinbase_tx(%Transaction{}, coinbase, @genesisCoinbaseData)],
        "Genesis"
      )

    for i <- 1..numNodes do
      GenServer.start_link(Peer, [i, genesis, wallets, numNodes], name: Peer.get_node_name(i))
    end

    for i <- 1..numNodes do
      GenServer.cast(Peer.get_node_name(i), {:initial_buy})
    end

    for i <- 1..numNodes do
      GenServer.cast(Peer.get_node_name(i), {:get_balance})
    end

    Process.sleep(:infinity)
  end
end
