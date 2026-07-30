defmodule Budgetron.LocationCategories.LocationCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "location_categories" do
    field :override, :boolean, default: false
    belongs_to :location, Budgetron.Locations.Location
    belongs_to :category, Budgetron.Categories.Category

    timestamps()
  end

  @doc false
  def changeset(location_category, attrs) do
    location_category
    |> cast(attrs, [:override, :location_id, :category_id])
    |> validate_required([:location_id, :category_id])
    |> validate_inclusion(:override, [true, false])
  end
end
