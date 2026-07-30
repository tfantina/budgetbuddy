defmodule Budgetron.Transactions do
  import Ecto.Query, warn: false
  alias Budgetron.Repo
  alias Budgetron.Transactions.Transaction

  @doc """
  Gets a transaction by ID.
  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Lists all transactions.
  """
  def list_transactions do
    Transaction
    |> join(:left, [t], l in assoc(t, :location))
    |> join(:left, [t], c in assoc(t, :category))
    |> select([t, l, c], {t, l, c})
    |> order_by([t], t.date)
    |> Repo.all()
  end

  @doc """
  Creates a transaction.
  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates multiple transactions.
  """
  def create_transactions(transactions) do
    Repo.transaction(fn ->
      Enum.map(transactions, &create_transaction/1)
    end)
  end

  @doc """
  Updates a transaction.
  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.
  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end
end
