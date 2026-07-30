defmodule BudgetronWeb.ImportController do
  use BudgetronWeb, :controller

  alias Budgetron.Imports
  alias Budgetron.Imports.CSVParser

  @doc """
  Shows the CSV upload form.
  """
  def new(conn, _params) do
    render(conn, :new)
  end

  @doc """
  Handles CSV file upload and shows column mapping form.
  """
  def create(conn, %{"csv" => %Plug.Upload{path: path, filename: filename}}) do
    # Read the CSV file
    {:ok, csv_content} = File.read(path)
    
    # Parse to get headers
    {headers, _rows} = CSVParser.parse_with_headers(csv_content)
    
    # Store CSV content in session for the next step
    conn
    |> put_session(:csv_content, csv_content)
    |> put_session(:csv_filename, filename)
    |> render(:column_mapping, headers: headers)
  end

  def create(conn, _params) do
    conn
    |> put_flash(:error, "No CSV file uploaded")
    |> redirect(to: ~p"/imports/new")
  end

  @doc """
  Handles column mapping submission and processes the import.
  """
  def process(conn, %{"column_mapping" => column_mapping}) do
    csv_content = get_session(conn, :csv_content)
    
    case Imports.process_import(csv_content, column_mapping) do
      {:ok, transactions} ->
        # Store transactions in session
        conn
        |> put_session(:import_transactions, transactions)
        |> redirect(to: ~p"/imports/review")
      {:error, reason} ->
        conn
        |> put_flash(:error, "Import failed: #{reason}")
        |> redirect(to: ~p"/imports/new")
    end
  end

  @doc """
  Shows the tinder mode for reviewing transactions.
  """
  def review(conn, _params) do
    transactions = get_session(conn, :import_transactions) || []
    
    conn
    |> assign(:transactions, transactions)
    |> render(:review)
  end
end
