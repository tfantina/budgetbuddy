defmodule Budgetron.Imports.CSVParser do
  @moduledoc """
  Parses CSV files for transaction imports.
  Uses a simple approach that handles most common CSV formats.
  """

  @doc """
  Parses a CSV string with headers and returns {headers, rows}.
  Each row is a map from header name to value.
  """
  def parse_with_headers(csv_string) do
    lines =
      csv_string
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    case lines do
      [] ->
        {[], []}

      [headers | rows] ->
        header_names = parse_csv_line(headers)

        parsed_rows =
          Enum.map(rows, fn row ->
            values = parse_csv_line(row)

            # Create a map from header names to values
            # Pad or truncate values to match header count
            values = pad_or_truncate(values, length(header_names))

            Enum.zip(header_names, values)
            |> Map.new()
          end)

        {header_names, parsed_rows}
    end
  end

  @doc """
  Parses a single CSV line into a list of values.
  Handles simple CSV (no quoted fields with commas inside).
  """
  def parse_csv_line(line) do
    String.split(line, ",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&remove_quotes/1)
  end

  defp remove_quotes(value) do
    String.replace(value, ~r/^"|"$/, "")
    |> String.replace("\"\"", "\"")
  end

  defp pad_or_truncate(values, length) do
    values = Enum.take(values, length)
    values = values ++ List.duplicate(nil, max(0, length - length(values)))
    values
  end
end
