defmodule Budgetron.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :event_type, :string, null: false
      add :aggregate_type, :string, null: false
      add :aggregate_id, :uuid, null: false
      add :data, :map, null: false
      add :timestamp, :integer, null: false
      add :version, :integer, null: false
      timestamps()
    end

    create unique_index(:events, [:aggregate_type, :aggregate_id, :version], name: :events_aggregate_id_version_unique)
    create index(:events, [:aggregate_type, :aggregate_id])
    create index(:events, [:timestamp])
    create index(:events, [:event_type])
  end
end
