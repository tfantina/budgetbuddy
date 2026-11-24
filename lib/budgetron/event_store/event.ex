defmodule Budgetron.EventStore.Event do
  use EctoTypedSchema
  import Ecto.Changeset

  typed_schema "events" do
    field :event_type, :string
    field :aggregate_type, :string
    field :aggregate_id, Ecto.UUID
    field :data, :map
    field :timestamp, :integer
    field :version, :integer

    timestamps()
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:event_type, :aggregate_type, :aggregate_id, :data, :timestamp, :version])
    |> validate_required([
      :event_type,
      :aggregate_type,
      :aggregate_id,
      :data,
      :timestamp,
      :version
    ])
  end
end
