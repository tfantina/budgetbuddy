defmodule Budgetron.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, :decimal
    field :date, :integer  # Unix timestamp
    field :memo, :string
    belongs_to :location, Budgetron.Locations.Location
    belongs_to :category, Budgetron.Categories.Category

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :date, :memo, :location_id, :category_id])
    |> validate_required([:amount, :date, :location_id])
    |> validate_number(:amount, greater_than: 0)
  end
end
