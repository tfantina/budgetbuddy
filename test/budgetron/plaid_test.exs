defmodule Budgetron.PlaidTest do
  use Budgetron.DataCase, async: true

  alias Budgetron.Plaid

  test "create_item requires item_id and access_token" do
    assert {:error, changeset} = Plaid.create_item(%{})
    assert errors_on(changeset)[:item_id] == ["can't be blank"]
    assert errors_on(changeset)[:access_token] == ["can't be blank"]
  end

  test "create_item persists and lists items" do
    assert {:ok, item} =
             Plaid.create_item(%{
               item_id: "item-1",
               access_token: "access-token-1",
               institution_name: "Test Bank"
             })

    assert [%{id: id}] = Plaid.list_items()
    assert Plaid.get_item!(id).item_id == "item-1"
    assert Plaid.get_item_by_item_id("item-1").institution_name == "Test Bank"
    assert item.item_id == "item-1"
  end

  test "duplicate item_id is rejected" do
    {:ok, _} = Plaid.create_item(%{item_id: "item-dup", access_token: "token"})
    assert {:error, changeset} = Plaid.create_item(%{item_id: "item-dup", access_token: "token2"})
    assert errors_on(changeset)[:item_id] == ["has already been taken"]
  end
end
