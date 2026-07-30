defmodule Budgetron.Locations.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :name, :string
    has_many :transactions, Budgetron.Transactions.Transaction
    has_many :location_categories, Budgetron.LocationCategories.LocationCategory

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
