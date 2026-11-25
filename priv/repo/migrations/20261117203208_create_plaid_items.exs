defmodule Budgetron.Repo.Migrations.CreatePlaidItems do
  use Ecto.Migration

  def change do
    create table(:plaid_items) do
      add :item_id, :string, null: false
      add :access_token, :string, null: false
      add :institution_id, :string
      add :institution_name, :string

      timestamps()
    end

    create unique_index(:plaid_items, [:item_id])
  end
end
