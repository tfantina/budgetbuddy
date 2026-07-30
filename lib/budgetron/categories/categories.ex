defmodule Budgetron.Categories do
  import Ecto.Query, warn: false
  alias Budgetron.Repo
  alias Budgetron.Categories.Category

  @doc """
  Gets a category by ID.
  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Gets a category by name (case-insensitive).
  """
  def get_category_by_name(name) do
    Category
    |> where([c], c.name == ^name)
    |> Repo.one()
  end

  @doc """
  Lists all categories.
  """
  def list_categories do
    Category
    |> order_by([c], c.name)
    |> Repo.all()
  end

  @doc """
  Creates a category.
  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.
  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.
  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end
end
