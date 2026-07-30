defmodule Budgetron.Imports.LocationMatcher do
  @moduledoc """
  Matches location names from CSV imports to existing locations using fuzzy matching.
  """

  alias Budgetron.Locations
  alias Budgetron.Locations.Location

  @doc """
  Finds or creates a location for the given name.
  
  Uses fuzzy matching to find existing locations that are similar.
  If no match is found, creates a new location.
  """
  def find_or_create_location(location_name) when is_binary(location_name) do
    location_name
    |> String.trim()
    |> do_find_or_create()
  end

  defp do_find_or_create(location_name) do
    # First, try exact match (case-insensitive)
    case find_exact_match(location_name) do
      %Location{} = location ->
        {:ok, location}
      nil ->
        # Try fuzzy match
        case find_fuzzy_match(location_name) do
          %Location{} = location ->
            {:ok, location}
          nil ->
            # Create new location
            Locations.create_location(%{name: location_name})
        end
    end
  end

  @doc """
  Finds an exact match for the location name (case-insensitive).
  """
  def find_exact_match(location_name) do
    normalized = normalize(location_name)
    
    Locations.list_locations()
    |> Enum.find(fn %Location{name: name} ->
      normalize(name) == normalized
    end)
  end

  @doc """
  Finds a fuzzy match for the location name.
  
  Uses substring matching on normalized names (lowercase, no spaces or hyphens).
  """
  def find_fuzzy_match(location_name) do
    normalized_query = normalize(location_name)
    
    Locations.list_locations()
    |> Enum.find(fn %Location{name: name} ->
      normalized_existing = normalize(name)
      
      # Check if one contains the other
      String.contains?(normalized_query, normalized_existing) ||
        String.contains?(normalized_existing, normalized_query)
    end)
  end

  @doc """
  Normalizes a location name for comparison.
  
  Converts to lowercase and removes spaces and hyphens.
  """
  def normalize(name) do
    name
    |> String.downcase()
    |> String.replace(" ", "")
    |> String.replace("-", "")
  end
end
