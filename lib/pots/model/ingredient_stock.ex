defmodule Pots.Model.IngredientStock do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, autogenerate: false}
  schema "ingredients" do
    field :amount, :integer
  end

  @doc false
  def changeset(ingredient_stock, attrs) do
    ingredient_stock
    |> cast(attrs, [:id, :amount])
    |> validate_required([:id, :amount])
    |> check_constraint(:amount, name: "non_neg_amount")
  end
end
