defmodule Pots.Data.Utils do
  alias Pots.Data.Ingredients

  def ing(ingredient_name, amount) do
    %{type: :ingredient, id: Ingredients.name_to_id!(ingredient_name), amount: amount}
  end
end
