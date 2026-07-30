defmodule Budgetron.Imports.Importer do
  @moduledoc """
  Main module for importing transactions from CSV files.
  """

  alias Budgetron.Locations
  alias Budgetron.Transactions
  alias Budgetron.Imports.CSVParser
  alias Budgetron.Imports.LocationMatcher
  alias Budgetron.Imports.Categorizer

  @doc """
  Imports transactions from a CSV file with the given column mapping.
  
  Returns a list of created transactions.
  """
  def import(csv_content, column_mapping) do
    # Parse CSV
    {headers, rows} = CSVParser.parse_with_headers(csv_content)
    
    # Map rows to transaction data
    mapped_rows = map_rows(rows, column_mapping)
    
    # Process each row: find/create location, create transaction
    transactions = 
      Enum.map(mapped_rows, fn row_data ->
        # Find or create location
        {:ok, location} = LocationMatcher.find_or_create_location(row_data.location)
        
        # Parse date to Unix timestamp
        timestamp = parse_date(row_data.date)
        
        # Parse amount
        amount = parse_amount(row_data.amount)
        
        # Create transaction
        Transactions.create_transaction(%{
          amount: amount,
          date: timestamp,
          memo: row_data.memo,
          location_id: location.id
        })
      end)
      |> Enum.filter(&match?({:ok, _}, &1))
      |> Enum.map(fn {:ok, t} -> t end)
    
    # Auto-categorize transactions
    categorized_transactions = Categorizer.categorize_all(transactions)
    
    # Update transactions with categories
    Enum.map(categorized_transactions, fn transaction ->
      if transaction.category_id do
        Transactions.update_transaction(transaction, %{category_id: transaction.category_id})
      else
        transaction
      end
    end)
    
    {:ok, categorized_transactions}
  end

  @doc """
  Maps CSV rows to transaction data based on column mapping.
  """
  defp map_rows(rows, column_mapping) do
    Enum.map(rows, fn row ->
      %{
        amount: row[column_mapping["amount"]],
        date: row[column_mapping["date"]],
        location: row[column_mapping["location"]],
        memo: row[column_mapping["memo"]]
      }
    end)
  end

  @doc """
  Parses a date string to Unix timestamp.
  
  Supports various date formats:
  - YYYY-MM-DD
  - MM/DD/YYYY
  - DD-MM-YYYY
  - And others via DateTime parsing
  """
  def parse_date(date_string) when is_binary(date_string) do
    date_string
    |> String.trim()
    |> parse_date_string()
  end

  defp parse_date_string(date_string) do
    # Try parsing as Date
    case Date.from_iso8601(date_string) do
      {:ok, date} ->
        # Convert Date to DateTime at start of day
        DateTime.new!(date, ~T[00:00:00])
        |> DateTime.to_unix()
      _ ->
        # Try other formats
        try do
          # Try MM/DD/YYYY or DD-MM-YYYY
          parts = String.split(date_string, ["/", "-"])
          
          case parts do
            [year, month, day] when byte_size(year) == 4 ->
              Date.from_iso8601("#{year}-#{month}-#{day}")
            [month, day, year] when byte_size(year) == 4 ->
              Date.from_iso8601("#{year}-#{month}-#{day}")
            [day, month, year] when byte_size(year) == 4 ->
              Date.from_iso8601("#{year}-#{month}-#{day}")
            _ ->
              # Try DateTime parsing
              DateTime.from_iso8601(date_string)
          end
          |> case do
            {:ok, %DateTime{} = dt} -> DateTime.to_unix(dt)
            {:ok, %Date{} = d} -> DateTime.new!(d, ~T[00:00:00]) |> DateTime.to_unix()
            _ -> 0  # Default to epoch if parsing fails
          end
        rescue
          _ -> 0
        end
    end
  end

  @doc """
  Parses an amount string to Decimal.
  
  Handles currency symbols and commas.
  """
  def parse_amount(amount_string) when is_binary(amount_string) do
    amount_string
    |> String.trim()
    |> String.replace(~r/[^\d.,-]/, "")
    |> String.replace(",", "")
    |> String.to_float()
    |> Decimal.from_float()
  end
end
