defmodule Budgetron.Plaid do
  @moduledoc """
  Plaid API client (link token, token exchange, accounts, balances, transactions)
  plus persistence for linked Plaid items.
  """
  import Ecto.Query, warn: false
  alias Budgetron.Plaid.Item
  alias Budgetron.Repo

  @base_urls %{
    "sandbox" => "https://sandbox.plaid.com",
    "development" => "https://development.plaid.com",
    "production" => "https://production.plaid.com"
  }

  defp config do
    Application.get_env(:budgetron, :plaid, [])
  end

  defp base_url do
    case config()[:base_url] do
      nil -> Map.fetch!(@base_urls, config()[:env] || "sandbox")
      url -> url
    end
  end

  defp credentials do
    %{client_id: config()[:client_id], secret: config()[:secret]}
  end

  defp post(path, body) do
    case Req.post(
           url: base_url() <> path,
           json: Map.merge(credentials(), body),
           headers: [{"plaid-version", "2018-05-22"}]
         ) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: status, body: body}} -> {:error, {status, body}}
      {:error, exception} -> {:error, exception}
    end
  end

  @doc """
  Creates a Link token used to open Plaid Link on the client.
  """
  def create_link_token(user_id, opts \\ []) do
    body = %{
      user: %{client_user_id: user_id},
      client_name: "Budgetron",
      products: ["auth", "transactions"],
      country_codes: ["CA"],
      language: "en"
    }

    body =
      case Keyword.get(opts, :update_item_id) do
        nil -> body
        item_id -> Map.put(body, :access_token, get_item!(item_id).access_token)
      end

    post("/link/token/create", body)
  end

  @doc """
  Exchanges a public token from Plaid Link for an access token + item id.
  """
  def exchange_public_token(public_token) do
    post("/item/public_token/exchange", %{public_token: public_token})
  end

  @doc """
  Fetches accounts for an access token.
  """
  def get_accounts(access_token) do
    post("/accounts/get", %{access_token: access_token})
  end

  @doc """
  Fetches real-time balances for an access token.
  """
  def get_balances(access_token) do
    post("/accounts/balance/get", %{access_token: access_token})
  end

  @doc """
  Fetches transactions between start_date and end_date (YYYY-MM-DD),
  following Plaid's pagination.
  """
  def get_transactions(access_token, start_date, end_date) do
    initial = %{
      access_token: access_token,
      start_date: start_date,
      end_date: end_date,
      options: %{count: 500, offset: 0}
    }

    fetch_all_transactions(initial, [])
  end

  defp fetch_all_transactions(req, acc) do
    case post("/transactions/get", req) do
      {:ok, %{"transactions" => txns, "total_transactions" => total}} ->
        new_acc = acc ++ txns
        offset = length(new_acc)

        if offset < total do
          fetch_all_transactions(%{req | options: %{count: 500, offset: offset}}, new_acc)
        else
          {:ok, new_acc}
        end

      {:error, _} = err ->
        err
    end
  end

  def list_items, do: Repo.all(Item)

  def get_item!(id), do: Repo.get!(Item, id)

  def get_item_by_item_id(item_id) do
    Repo.get_by(Item, item_id: item_id)
  end

  def create_item(attrs) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def delete_item(%Item{} = item), do: Repo.delete(item)
end
