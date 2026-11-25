defmodule BudgetronWeb.PlaidLive do
  use BudgetronWeb, :live_view

  alias Budgetron.Plaid

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Bank Accounts")
     |> assign(:items, Plaid.list_items())
     |> assign(:accounts, [])
     |> assign(:transactions, [])
     |> assign(:error, nil)
     |> assign(:connecting, false)
     |> refresh_accounts()}
  end

  @impl true
  def handle_event("connect", _params, socket) do
    case Plaid.create_link_token("budgetron-user") do
      {:ok, %{"link_token" => link_token}} ->
        {:noreply,
         socket
         |> assign(:connecting, true)
         |> push_event("plaid:link_token", %{link_token: link_token})}

      {:error, err} ->
        {:noreply, assign(socket, :error, "Could not create link token: #{inspect(err)}")}
    end
  end

  @impl true
  def handle_event("plaid_error", %{"message" => message}, socket) do
    {:noreply, socket |> assign(:connecting, false) |> assign(:error, message)}
  end

  @impl true
  def handle_event("exchange_public_token", %{"public_token" => public_token} = params, socket) do
    with {:ok, %{"access_token" => access_token, "item_id" => item_id}} <-
           Plaid.exchange_public_token(public_token),
         {:ok, _item} <-
           Plaid.create_item(%{
             item_id: item_id,
             access_token: access_token,
             institution_id: params["institution_id"],
             institution_name: params["institution_name"]
           }) do
      {:noreply,
       socket
       |> assign(:error, nil)
       |> assign(:connecting, false)
       |> assign(:items, Plaid.list_items())
       |> refresh_accounts()}
    else
      {:error, err} ->
        {:noreply,
         socket
         |> assign(:connecting, false)
         |> assign(:error, "Token exchange failed: #{inspect(err)}")}
    end
  end

  @impl true
  def handle_event("load_transactions", _params, socket) do
    end_date = Date.utc_today()
    start_date = Date.add(end_date, -30)

    results =
      Enum.map(socket.assigns.items, fn item ->
        Plaid.get_transactions(
          item.access_token,
          Date.to_string(start_date),
          Date.to_string(end_date)
        )
      end)

    case Enum.find(results, &match?({:error, _}, &1)) do
      {:error, err} ->
        {:noreply, assign(socket, :error, "Could not load transactions: #{inspect(err)}")}

      nil ->
        transactions =
          results
          |> Enum.flat_map(fn {:ok, txns} -> txns end)
          |> Enum.sort_by(& &1["date"], :desc)

        {:noreply, assign(socket, :transactions, transactions)}
    end
  end

  defp format_money(nil, _currency), do: "-"

  defp format_money(amount, currency) do
    "#{currency || "USD"} #{:erlang.float_to_binary(amount * 1.0, decimals: 2)}"
  end

  defp refresh_accounts(socket) do
    accounts =
      socket.assigns.items
      |> Enum.flat_map(fn item ->
        with {:ok, %{"accounts" => accounts}} <- Plaid.get_accounts(item.access_token),
             {:ok, %{"accounts" => balances}} <- Plaid.get_balances(item.access_token) do
          balances_by_id = Map.new(balances, &{&1["account_id"], &1["balances"]})

          Enum.map(accounts, fn account ->
            Map.put(account, "balances", Map.get(balances_by_id, account["account_id"]))
          end)
        else
          _ -> []
        end
      end)

    assign(socket, :accounts, accounts)
  end
end
