defmodule Pots.Data.Ingredients do
  @ingredients [
    %{id: 1, name: "Green Tea", price: 100}
  ]
  def list do
    @ingredients
  end

  Enum.each(@ingredients, fn ing ->
    %{id: id} = ing
    def fetch(unquote(id)), do: {:ok, unquote(Macro.escape(ing))}
  end)

  def fetch(_), do: {:error, :not_found}
end
