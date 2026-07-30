defmodule Budgetron.Repo do
  use Ecto.Repo,
    otp_app: :budgetron,
    adapter: Ecto.Adapters.SQLite3
end
