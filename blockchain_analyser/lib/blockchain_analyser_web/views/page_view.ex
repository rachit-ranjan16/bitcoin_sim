defmodule BlockchainAnalyserWeb.PageView do
  use BlockchainAnalyserWeb, :view

  def handler_info(conn) do
    # "#{Kernal.inspect(get_session(conn,:balance))}"
    "helleo"
  end

  def connection_keys(conn) do
    conn
    |> Map.from_struct()
    |> Map.keys()
  end

  def get_balance_object(conn) do
    Jason.encode!(get_session(conn, :balance))
  end

  def get_trans_time_map_object(conn) do
    Jason.encode!(get_session(conn, :trans_time_map))
  end
end
