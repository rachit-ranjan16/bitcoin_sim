defmodule BlockchainAnalyserWeb.Router do
  use BlockchainAnalyserWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # pipeline :csrf do
  #   plug :protect_from_forgery # to here
  # end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BlockchainAnalyserWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/start", PageController, :start
    get "/balance", PageController, :balance
    get "/transaction_time", PageController, :transaction_time
  end
end
