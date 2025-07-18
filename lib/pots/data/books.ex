defmodule Pots.Data.Books do
  alias Pots.Data.Ingredients
  import Pots.Data.Utils

  @books [
           %{
             name: "Torn Shopping List",
             price: price(0),
             recipes: [
               %{
                 name: "Tea",
                 description: "It's just Tea.",
                 price: price(4),
                 components: [
                   ing("Green Tea", 1)
                 ]
               },
               %{
                 name: "Mint Tea",
                 description: "So sweet!",
                 price: price(30),
                 components: [
                   ing("Green Tea", 1),
                   ing("Mint Sprig", 2),
                   ing("Sugar", 1)
                 ]
               }
             ]
           },
           %{name: "Faded Page of Scribbles", price: price(10), recipes: []},
           %{name: "Greasy Kitchen Note", price: price(20), recipes: []},
           %{name: "Worn Pocket Almanac", price: price(30), recipes: []},
           %{name: "Stained Apprentice Handbook", price: price(45), recipes: []},
           %{name: "Leatherbound Recipe Journal", price: price(120), recipes: []},
           %{name: "Embroidered Field Manual", price: price(160), recipes: []},
           %{name: "Gilded Tome of Elixirs", price: price(210), recipes: []},
           %{name: "Gilded Tome of Elixirs vol. II", price: price(210), recipes: []}
           #  %{name: "Ancient Illuminated Manuscript", price: price(700), recipes: []},
           #  %{name: "Mythic Scroll of Forgotten Brews", price: price(1000), recipes: []}
         ]
         |> Enum.with_index(1)
         |> Enum.map(fn {item, index} ->
           Map.merge(item, %{id: index, n_recipes: length(item.recipes)})
         end)

  # Ensure all recipes make a profit.
  @books
  |> Enum.flat_map(& &1.recipes)
  |> Enum.each(fn recipe ->
    components_price =
      Enum.reduce(recipe.components, 0, fn comp, acc ->
        %{type: :ingredient, id: id, amount: amount} = comp
        {:ok, %{price: price}} = Ingredients.fetch(id)
        acc + price * amount
      end)

    if components_price >= recipe.price do
      IO.puts("----------")

      Enum.map(recipe.components, fn comp ->
        %{type: :ingredient, id: id, amount: amount} = comp
        {:ok, %{name: name, price: price}} = Ingredients.fetch(id)
        IO.puts("#{name}: #{price} * #{amount} = #{price * amount}")
      end)

      IO.puts("components price: #{components_price}")
      IO.puts("sell price:       #{recipe.price}")
      raise ArgumentError, "sell price of #{recipe.name} is lower than components price"
    end
  end)

  def list do
    @books
  end

  Enum.each(@books, fn item ->
    %{id: id} = item
    def fetch(unquote(id)), do: {:ok, unquote(Macro.escape(item))}
  end)

  def fetch(_), do: {:error, :not_found}
end
