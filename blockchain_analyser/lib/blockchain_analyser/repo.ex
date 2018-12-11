defmodule BlockchainAnalyser.Repo do
  use Ecto.Repo,
    otp_app: :blockchain_analyser,
    adapter: Ecto.Adapters.Postgres
end
