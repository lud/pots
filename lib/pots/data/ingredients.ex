defmodule Pots.Data.Ingredients do
  @ingredients [
                 %{name: "Green Tea", price: 1},
                 %{name: "Dandelion Leaf", price: 2},
                 %{name: "Sugar", price: 1},
                 %{name: "Wild Mushroom", price: 10},
                 %{name: "Honeycomb", price: 20},
                 %{name: "Mint Sprig", price: 2},
                 %{name: "Garlic Clove", price: 8},
                 %{name: "River Pebble", price: 5},
                 %{name: "Pine Needle", price: 6},
                 %{name: "Chicken Feather", price: 7},
                 %{name: "Apple Seed", price: 9},
                 %{name: "Chamomile Flower", price: 14},
                 %{name: "Carrot Top", price: 10},
                 %{name: "Salt Crystal", price: 5},
                 %{name: "Basil Leaf", price: 11},
                 %{name: "Onion Skin", price: 6},
                 %{name: "Peppercorn", price: 8},
                 %{name: "Thyme Sprig", price: 10},
                 %{name: "Rose Petal", price: 13},
                 %{name: "Acorn Cap", price: 7},
                 %{name: "Lemon Zest", price: 12},
                 %{name: "Eggshell Shard", price: 6},
                 %{name: "Mandrake Root", price: 120},
                 %{name: "Phoenix Feather", price: 450},
                 %{name: "Goblin Earwax", price: 80},
                 %{name: "Moonlit Dew", price: 200},
                 %{name: "Dragon Scale", price: 350},
                 %{name: "Unicorn Hair", price: 500},
                 %{name: "Pixie Dust", price: 300},
                 %{name: "Vampire Fang", price: 275},
                 %{name: "Werewolf Fur", price: 180},
                 %{name: "Mermaid Tear", price: 220},
                 %{name: "Witch’s Wart", price: 90},
                 %{name: "Stardust Petals", price: 240},
                 %{name: "Chameleon Tongue", price: 110},
                 %{name: "Basilisk Venom", price: 400},
                 %{name: "Ghost Orchid", price: 150},
                 %{name: "Troll Fat", price: 70},
                 %{name: "Fairy Wing", price: 260},
                 %{name: "Thunder Egg", price: 320},
                 %{name: "Sleepy Poppy", price: 60},
                 %{name: "Lunar Moth Dust", price: 210}
               ]
               |> Enum.with_index(1)
               |> Enum.map(fn {item, index} -> Map.put(item, :id, index) end)

  def list do
    @ingredients
  end

  Enum.each(@ingredients, fn item ->
    %{id: id} = item
    def fetch(unquote(id)), do: {:ok, unquote(Macro.escape(item))}
  end)

  def fetch(_), do: {:error, :not_found}

  def fetch!(id) do
    case fetch(id) do
      {:ok, ing} -> ing
      {:error, :not_found} -> raise ArgumentError, "unknown ingredient id #{id}"
    end
  end

  Enum.each(@ingredients, fn item ->
    %{id: id, name: name} = item
    def name_to_id!(unquote(name)), do: unquote(id)
  end)
end
