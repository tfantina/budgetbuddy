defmodule Budgetron.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :amount, :decimal, null: false
      add :date, :integer, null: false  # Unix timestamp
      add :memo, :string
      add :location_id, references(:locations, on_delete: :nothing), null: false
      add :category_id, references(:categories, on_delete: :nothing)
      timestamps()
    end

    create index(:transactions, [:location_id])
    create index(:transactions, [:category_id])
    create index(:transactions, [:date])
  end
end
