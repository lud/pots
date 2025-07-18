defmodule Pots.Repo.Migrations.CreateRecipes do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :name, :string
      add :description, :string
      add :components, :map
      add :price, :integer
    end
  end
end
