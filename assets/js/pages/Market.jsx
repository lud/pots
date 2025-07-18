import React from "react"
import { router } from "@inertiajs/react"

function formatPrice(cents) {
  return (cents / 100).toFixed(2)
}

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
  console.log(`props`, props)
  return (
    <div>
      <table className="table table-sm">
        <thead>
          <tr>
            <th>Ingredient</th>
            <th>Owned</th>
            <th>Price</th>
            <th style={{ width: "110px" }}></th>
          </tr>
        </thead>
        <tbody>
          {props.ingredients.map((ing) => (
            <tr key={ing.id}>
              <td>{ing.name}</td>
              <td>
                {formatIngredientStock(ing.id, props.inventory_ingredients)}
              </td>
              <td>{formatPrice(ing.price)}</td>
              <td>
                <div className="flex">
                  <button
                    className="btn btn-neutral btn-xs"
                    onClick={() => buyIngredient(ing.id)}
                  >
                    Buy
                  </button>

                  <button className="btn btn-neutral btn-xs ml-2">Sell</button>
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
