defmodule Pots.Repo.Migrations.CreateIngredients do
  use Ecto.Migration

  def change do
    create table(:ingredients) do
      add :amount, :integer, null: false, check: %{name: "non_neg_amount", expr: "amount >= 0"}
    end
  end
end
