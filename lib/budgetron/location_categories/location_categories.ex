defmodule Budgetron.LocationCategories do
  import Ecto.Query, warn: false
  alias Budgetron.Repo
  alias Budgetron.LocationCategories.LocationCategory

  @doc """
  Gets a location-category by ID.
  """
  def get_location_category!(id), do: Repo.get!(LocationCategory, id)

  @doc """
  Lists all location-categories for a location.
  """
  def list_by_location(location_id) do
    LocationCategory
    |> where([lc], lc.location_id == ^location_id)
    |> order_by([lc], desc: lc.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets the most recent non-override location-category for a location.
  Used for auto-categorization.
  """
  def get_default_for_location(location_id) do
    list_by_location(location_id)
    |> determine_default_category()
  end

  @doc """
  Creates a location-category.
  """
  def create_location_category(attrs \\ %{}) do
    %LocationCategory{}
    |> LocationCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a location-category.
  """
  def update_location_category(%LocationCategory{} = location_category, attrs) do
    location_category
    |> LocationCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Creates or updates a location-category for a transaction.
  When a user manually sets a category on a transaction, we record this in location_categories.
  """
  def record_transaction_category(transaction) do
    %LocationCategory{}
    |> LocationCategory.changeset(%{
      location_id: transaction.location_id,
      category_id: transaction.category_id,
      override: true
    })
    |> Repo.insert()
  end

  @doc """
  Determines the default category for a location based on its location-category history.

  Logic:
  - If there are no location-categories, return nil
  - If the most recent has override=false, use it
  - If the most recent has override=true:
    - If there's a previous non-override, use that (one-off override)
    - Otherwise, use the most recent override (pattern has changed)
  """
  def determine_default_category(location_categories) do
    case location_categories do
      [] ->
        nil

      [first | rest] ->
        if !first.override do
          first.category
        else
          # Most recent is override, check if there's a previous non-override
          case Enum.find(rest, &(!&1.override)) do
            # All are overrides, use the most recent
            nil -> first.category
            # Use the previous non-override
            non_override -> non_override.category
          end
        end
    end
  end
end
