defmodule BudgetronWeb.ImportLive do
  use BudgetronWeb, :live_view

  alias Budgetron.Transactions
  alias Budgetron.Categories
  alias Budgetron.LocationCategories
  import BudgetronWeb.Helpers.DateHelpers

  @impl true
  def mount(_params, _session, socket) do
    # For now, we'll pass transactions via assigns
    # In a real implementation, we'd get them from the import run
    transactions = socket.assigns[:transactions] || []
    categories = Categories.list_categories()
    
    socket =
      socket
      |> assign(:transactions, transactions)
      |> assign(:categories, categories)
      |> assign(:current_index, 0)
      |> assign(:current_transaction, List.first(transactions))
      |> assign(:completed, false)
    
    {:ok, socket}
  end

  @impl true
  def handle_event("next", _params, socket) do
    {current_index, transactions} = {socket.assigns.current_index, socket.assigns.transactions}
    
    if current_index < length(transactions) - 1 do
      next_index = current_index + 1
      next_transaction = Enum.at(transactions, next_index)
      
      socket =
        socket
        |> assign(:current_index, next_index)
        |> assign(:current_transaction, next_transaction)
      
      {:noreply, socket}
    else
      # All transactions reviewed
      socket =
        socket
        |> assign(:completed, true)
      
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("prev", _params, socket) do
    {current_index, transactions} = {socket.assigns.current_index, socket.assigns.transactions}
    
    if current_index > 0 do
      prev_index = current_index - 1
      prev_transaction = Enum.at(transactions, prev_index)
      
      socket =
        socket
        |> assign(:current_index, prev_index)
        |> assign(:current_transaction, prev_transaction)
      
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("set_category", %{"category_id" => category_id}, socket) do
    current_transaction = socket.assigns.current_transaction
    
    # Skip if no transaction or category not changed
    if !current_transaction || current_transaction.category_id == String.to_integer(category_id) do
      {:noreply, socket}
    else
      # Update transaction category
      {:ok, updated_transaction} = 
        Transactions.update_transaction(
          current_transaction,
          %{category_id: String.to_integer(category_id)}
        )
      
      # Record this in location_categories
      if updated_transaction do
        LocationCategories.record_transaction_category(updated_transaction)
      end
      
      # Move to next transaction
      handle_event("next", %{}, socket)
    end
  end

  @impl true
  def handle_event("skip", _params, socket) do
    # Just move to next without setting category
    handle_event("next", %{}, socket)
  end
end
