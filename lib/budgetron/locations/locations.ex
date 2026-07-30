defmodule Budgetron.Locations do
  import Ecto.Query, warn: false
  alias Budgetron.Repo
  alias Budgetron.Locations.Location

  @doc """
  Gets a location by ID.
  """
  def get_location!(id), do: Repo.get!(Location, id)

  @doc """
  Gets a location by name (case-insensitive).
  """
  def get_location_by_name(name) do
    Repo.get_by(Location, name: name)
  end

  @doc """
  Lists all locations.
  """
  def list_locations do
    Location
    |> order_by([l], l.name)
    |> Repo.all()
  end

  @doc """
  Creates a location.
  """
  def create_location(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a location.
  """
  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a location.
  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Finds locations matching a normalized name.
  Uses fuzzy matching: checks if one normalized name contains the other.
  """
  def find_matching_locations(query_string) do
    normalized_query = normalize(query_string)
    pattern = "%" <> normalized_query <> "%"

    Location
    |> where([l], fragment("LOWER(REPLACE(REPLACE(?, ' ', ''), '-', '')) LIKE ?", l.name, ^pattern))
    |> Repo.all()
  end

  @doc """
  Normalizes a location name for fuzzy matching.
  """
  def normalize(name) do
    name
    |> String.downcase()
    |> String.replace(" ", "")
    |> String.replace("-", "")
  end
end
