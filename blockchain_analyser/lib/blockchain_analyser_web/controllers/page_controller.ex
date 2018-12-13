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
    GenServer.start_link(BitcoinSim, [100, 20], name: :bitcoin_sim)
    GenServer.cast(:bitcoin_sim, {:initiate})
    render(conn, "start.html")
  end

  def transaction_time(conn, _params) do
    trans_time_list = GenServer.call(:bitcoin_sim, {:get_trans_time}, 30000)
    trans_time_map = 1..length(trans_time_list) |> Stream.zip(trans_time_list) |> Enum.into(%{})
    conn = put_session(conn, :trans_time_map, trans_time_map)
    GenServer.cast(:bitcoin_sim, {:transact})
    render(conn, "transaction_time.html")
  end
end
