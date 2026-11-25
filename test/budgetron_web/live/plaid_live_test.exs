defmodule BudgetronWeb.PlaidLiveTest do
  use BudgetronWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders plaid page with connect button", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/plaid")

    assert html =~ "Bank Accounts"
    assert has_element?(view, "#connect-bank-btn")
    assert has_element?(view, "#load-transactions-btn")
    assert has_element?(view, "#plaid-link")
  end

  test "shows connected items after linking", %{conn: conn} do
    {:ok, _item} =
      Budgetron.Plaid.create_item(%{
        item_id: "item-test",
        access_token: "token",
        institution_name: "Test Bank"
      })

    {:ok, _view, html} = live(conn, ~p"/plaid")

    assert html =~ "Test Bank"
  end
end
