defmodule Budgetron.EventStore do
  @moduledoc """
  Event store for event sourcing.
  """

  import Ecto.Query, warn: false
  alias Budgetron.Repo
  alias Budgetron.EventStore.Event

  @doc """
  Appends an event to the event store.
  """
  def append_event(attrs) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Loads all events for an aggregate.
  """
  def load_events(aggregate_type, aggregate_id) do
    Event
    |> where([e], e.aggregate_type == ^aggregate_type and e.aggregate_id == ^aggregate_id)
    |> order_by([e], e.version)
    |> Repo.all()
  end

  @doc """
  Gets the next version number for an aggregate.
  """
  def next_version(aggregate_type, aggregate_id) do
    case last_event(aggregate_type, aggregate_id) do
      nil -> 1
      %Event{version: version} -> version + 1
    end
  end

  @doc """
  Gets the last event for an aggregate.
  """
  def last_event(aggregate_type, aggregate_id) do
    Event
    |> where([e], e.aggregate_type == ^aggregate_type and e.aggregate_id == ^aggregate_id)
    |> order_by([e], desc: e.version)
    |> Repo.one()
  end

  @doc """
  Changeset for Event.
  """
  def changeset(event, attrs) do
    event
    |> Ecto.Changeset.cast(attrs, [
      :event_type,
      :aggregate_type,
      :aggregate_id,
      :data,
      :timestamp,
      :version
    ])
    |> Ecto.Changeset.validate_required([
      :event_type,
      :aggregate_type,
      :aggregate_id,
      :data,
      :timestamp,
      :version
    ])
    |> Ecto.Changeset.unique_constraint(:aggregate_id,
      name: :events_aggregate_id_version_unique,
      message: "version already exists"
    )
  end
end
