defmodule BudgetronWeb.Helpers.DateHelpers do
  @moduledoc """
  Date formatting helpers for the web interface.
  """

  @doc """
  Formats a Unix timestamp as a date string.
  """
  def format_date(timestamp) when is_integer(timestamp) do
    DateTime.from_unix!(timestamp)
    |> DateTime.to_date()
    |> to_string()
  end

  def format_date(_), do: "N/A"
end
