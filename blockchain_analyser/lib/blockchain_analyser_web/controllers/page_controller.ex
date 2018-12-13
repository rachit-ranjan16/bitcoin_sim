defmodule BlockchainAnalyserWeb.PageController do
  use BlockchainAnalyserWeb, :controller
  use GenServer
  # import Some

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def balance(conn, _params) do
    balances = GenServer.call(:bitcoin_sim, {:get_balances})
    conn = put_session(conn, :balance, balances)
    render(conn, "balances.html")
  end

  def start(conn, params) do
    # BitcoinSim.driver(["10","10"])
    GenServer.start_link(BitcoinSim, [10, 10], name: :bitcoin_sim)
    GenServer.cast(:bitcoin_sim, {:initiate})
    Process.sleep(10000)
    render(conn, "start.html")

    # render(conn, "index.html")
  end
end
