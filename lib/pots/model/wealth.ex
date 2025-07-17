defmodule Pots.Model.Wealth do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:currency, :integer, autogenerate: false}
  schema "wealth" do
    field :amount, :integer
  end

  def default_currency, do: 1

  @doc false
  def changeset(wealth, attrs) do
    wealth
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
    |> check_constraint(:amount, name: "non_neg_amount")
  end
end
