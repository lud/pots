defmodule Pots.Model.IngredientStock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ingredients" do
    field :amount, :integer
  end

  @doc false
  def changeset(ingredient_stock, attrs) do
    ingredient_stock
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
  end
end
