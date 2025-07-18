defmodule Pots.Model.OwnedBooks do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, autogenerate: false}
  schema "books" do
  end

  @doc false
  def changeset(owned_books, attrs) do
    owned_books
    |> cast(attrs, [:id])
    |> validate_required([:id])
  end
end
