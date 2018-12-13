defmodule BlockchainAnalyserWeb.PageController do
  use BlockchainAnalyserWeb, :controller
  use GenServer
  # import Some

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def start(conn, params) do
    # BitcoinSim.driver(["10","10"])
    GenServer.start_link(BitcoinSim, [10, 10], name: :bitcoin_sim)
    GenServer.cast(:bitcoin_sim, {:initiate})
    Process.sleep(10000)
    balances = GenServer.call(:bitcoin_sim, {:get_balances})
    IO.inspect(balances)
    # IO.inspect Map.get(balances, "Elixir.N0002")
    # x=elem(Enum.at(:ets.lookup(:cache,Peer.get_node_name_string(1)), 0), 1)
    # text conn, "#{Kernel.inspect(balances)}"
    # :ets.new(:cache, [:set, :public, :named_table])
    # :ets.insert(:cache,{:balance,balances})
    conn = put_session(conn, :balance, balances)
    render(conn, "balances.html")

    # render(conn, "index.html")
  end
end
