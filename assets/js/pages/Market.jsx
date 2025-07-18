import React from "react"
import { router } from "@inertiajs/react"
import { formatPrice } from "../utils"

// TODO we need to use regular ajax here so we do not add the called route into
// the browser history. We should fetch() and router.reload() with preserve
// scroll.
function buyIngredient(id) {
  router.post("/market/buy", {
    type: "ingredient",
    id,
    amount: 1,
  })
}

function formatIngredientStock(id, inventory) {
  const stock = inventory[id]
  if (typeof stock === "number") {
    return stock.toString()
  } else return ""
}

function Market(props) {
  const canAfford = (price) => props.wealth >= price
  return (
    <div>
      <table className="table table-sm">
        <thead>
          <tr>
            <th>Ingredient</th>
            <th>Owned</th>
            <th style={{ width: "110px", textAlign: "right" }}>Price</th>
          </tr>
        </thead>
        <tbody>
          {props.ingredients.map((ing) => (
            <tr key={ing.id}>
              <td>{ing.name}</td>
              <td>
                {formatIngredientStock(ing.id, props.inventory_ingredients)}
              </td>
              <td>
                <div className="flex gap-1 justify-end items-center">
                  <span>{formatPrice(ing.price)}</span>
                  <button
                    className={`btn btn-xs ${
                      canAfford(ing.price) ? "btn-neutral" : "btn-disabled"
                    }`}
                    onClick={() => buyIngredient(ing.id)}
                    disabled={!canAfford(ing.price)}
                  >
                    Buy
                  </button>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

export default Market
