defmodule Pots.Data.Ingredients do
  import Pots.Data.Utils

  @ingredients [
                 %{name: "Green Tea", price: price(1)},
                 %{name: "Dandelion Leaf", price: price(2)},
                 %{name: "Sugar", price: price(2)},
                 %{name: "Wild Mushroom", price: price(10)},
                 %{name: "Honeycomb", price: price(20)},
                 %{name: "Mint Sprig", price: price(12)},
                 %{name: "Garlic Clove", price: price(8)},
                 %{name: "River Pebble", price: price(5)},
                 %{name: "Pine Needle", price: price(6)},
                 %{name: "Chicken Feather", price: price(7)},
                 %{name: "Apple Seed", price: price(9)},
                 %{name: "Chamomile Flower", price: price(14)},
                 %{name: "Carrot Top", price: price(10)},
                 %{name: "Salt Crystal", price: price(5)},
                 %{name: "Basil Leaf", price: price(11)},
                 %{name: "Onion Skin", price: price(6)},
                 %{name: "Peppercorn", price: price(8)},
                 %{name: "Thyme Sprig", price: price(10)},
                 %{name: "Rose Petal", price: price(13)},
                 %{name: "Acorn Cap", price: price(7)},
                 %{name: "Lemon Zest", price: price(12)},
                 %{name: "Eggshell Shard", price: price(6)},
                 %{name: "Mandrake Root", price: price(120)},
                 %{name: "Phoenix Feather", price: price(450)},
                 %{name: "Goblin Earwax", price: price(80)},
                 %{name: "Moonlit Dew", price: price(200)},
                 %{name: "Dragon Scale", price: price(350)},
                 %{name: "Unicorn Hair", price: price(500)},
                 %{name: "Pixie Dust", price: price(300)},
                 %{name: "Vampire Fang", price: price(275)},
                 %{name: "Werewolf Fur", price: price(180)},
                 %{name: "Mermaid Tear", price: price(220)},
                 %{name: "Witch’s Wart", price: price(90)},
                 %{name: "Stardust Petals", price: price(240)},
                 %{name: "Chameleon Tongue", price: price(110)},
                 %{name: "Basilisk Venom", price: price(400)},
                 %{name: "Ghost Orchid", price: price(150)},
                 %{name: "Troll Fat", price: price(70)},
                 %{name: "Fairy Wing", price: price(260)},
                 %{name: "Thunder Egg", price: price(320)},
                 %{name: "Sleepy Poppy", price: price(60)},
                 %{name: "Lunar Moth Dust", price: price(210)}
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

  Enum.each(@ingredients, fn item ->
    %{id: id, name: name} = item
    def name_to_id!(unquote(name)), do: unquote(id)
  end)
end
