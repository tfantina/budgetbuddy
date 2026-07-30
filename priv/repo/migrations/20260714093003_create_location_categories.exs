defmodule Budgetron.Repo.Migrations.CreateLocationCategories do
  use Ecto.Migration

  def change do
    create table(:location_categories) do
      add :override, :boolean, default: false, null: false
      add :location_id, references(:locations, on_delete: :delete_all), null: false
      add :category_id, references(:categories, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:location_categories, [:location_id])
    create index(:location_categories, [:category_id])
    create index(:location_categories, [:location_id, :inserted_at])
  end
end
