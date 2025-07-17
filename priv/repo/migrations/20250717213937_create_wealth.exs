defmodule Pots.Repo.Migrations.CreateWealth do
  use Ecto.Migration

  def change do
    create table(:wealth, primary_key: false) do
      add :currency, :integer, primary_key: true
      add :amount, :integer, null: false
    end
  end
end
