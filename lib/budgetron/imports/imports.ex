defmodule Budgetron.Imports do
  @moduledoc """
  Context for handling CSV imports.
  """

  alias Budgetron.Imports.Importer

  @doc """
  Processes a CSV import with the given column mapping.
  
  column_mapping is a map like:
  %{
    "amount" => "Amount",
    "date" => "Date", 
    "location" => "Description",
    "memo" => "Memo"
  }
  
  Returns {:ok, transactions} or {:error, reason}.
  """
  def process_import(csv_content, column_mapping) do
    Importer.import(csv_content, column_mapping)
  end
end
