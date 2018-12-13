defmodule BlockchainAnalyserWeb.PageController do
  use BlockchainAnalyserWeb, :controller
  use GenServer
  # import Some

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def start(conn, params) do
    # BitcoinSim.driver(["10","10"])
    :ets.new(:cache, [:set, :public, :named_table])
    GenServer.start_link(BitcoinSim,[:cache,10,100], name: :bitcoin_sim)
    GenServer.cast(:bitcoin_sim, {:initiate})
    Process.sleep(10000)
    GenServer.cast(:bitcoin_sim, {:get_balance})
    Process.sleep(1000)
    IO.puts Kernel.inspect :ets.lookup(:cache,Peer.get_node_name_string(1))
    # x=elem(Enum.at(:ets.lookup(:cache,Peer.get_node_name_string(1)), 0), 1)
    text conn, "done"
    # render(conn, "index.html")
  end
end
