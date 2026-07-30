defmodule Budgetron.EventStore.Event do
  use TypedSchema
  use Ecto.Schema

  @type event_type :: :transaction_created | :transaction_updated | :transaction_deleted | :category_month_created | :category_month_updated | :category_month_amount_set | :category_month_rolled_over
  @type aggregate_type :: :transaction | :category_month

  @typedoc """
  Event store entry for event sourcing.
  """
  @type t :: %__MODULE__{}
  typed_schema do
    field :event_type, event_type(), { :atom, [] }:: event_type
    field :aggregate_type, aggregate_type(), { :atom, [] }:: aggregate_type
    field :aggregate_id, UUID.t(), { :uuid, [] }:: UUID.t()
    field :data, :map, { :map, [] }:: :map
    field :timestamp, :integer, { :integer, [] }:: :integer
    field :version, :integer, { :integer, [] }:: :integer
  end

  schema "events" do
    field :event_type, :atom
    field :aggregate_type, :atom
    field :aggregate_id, :uuid
    field :data, :map
    field :timestamp, :integer
    field :version, :integer

    timestamps()
  end
end
