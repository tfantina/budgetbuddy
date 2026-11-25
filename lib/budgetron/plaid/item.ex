defmodule Budgetron.Plaid.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plaid_items" do
    field :item_id, :string
    field :access_token, :string
    field :institution_id, :string
    field :institution_name, :string

    timestamps()
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:item_id, :access_token, :institution_id, :institution_name])
    |> validate_required([:item_id, :access_token])
    |> unique_constraint(:item_id)
  end
end
