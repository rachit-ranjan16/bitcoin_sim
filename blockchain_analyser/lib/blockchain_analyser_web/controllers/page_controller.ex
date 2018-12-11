defmodule BlockchainAnalyserWeb.PageController do
  use BlockchainAnalyserWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
