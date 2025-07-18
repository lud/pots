defmodule Pots.Model.KnownRecipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recipes" do
    field :name, :string
    field :description, :string

    embeds_many :components, Component, primary_key: false do
      field :type, Ecto.Enum, values: [:ingredient]
      field :id, :integer
      field :amount, :integer
    end

    field :price, :integer
  end

  @doc false
  def changeset(known_recipe, attrs) do
    known_recipe
    |> cast(attrs, [:name, :description, :price])
    |> cast_embed(:components, with: &component_changeset/2)
    |> validate_required([:name, :description, :price])
  end

  def component_changeset(component, attrs) do
    component
    |> cast(attrs, [:type, :id, :amount])
    |> validate_required([:type, :id, :amount])
  end
end
