defmodule BudgetronWeb.PageController do
  use BudgetronWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
