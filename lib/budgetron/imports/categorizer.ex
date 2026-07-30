defmodule Budgetron.Imports.Categorizer do
  @moduledoc """
  Auto-categorizes transactions based on location-category history.
  """

  alias Budgetron.LocationCategories

  @doc """
  Categorizes a single transaction based on its location's history.
  
  Returns the transaction with category_id set if a match is found.
  """
  def categorize(transaction) do
    location_id = transaction.location_id
    
    case LocationCategories.get_default_for_location(location_id) do
      nil ->
        transaction  # No category found, return as-is
      %Budgetron.Categories.Category{id: category_id} ->
        %{transaction | category_id: category_id}
    end
  end

  @doc """
  Categorizes multiple transactions.
  """
  def categorize_all(transactions) do
    Enum.map(transactions, &categorize/1)
  end
end
