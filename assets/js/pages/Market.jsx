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

function Market(props) {
  console.log(`props`, props)
  return (
    <div>
      <table className="table">
        <thead>
          <tr>
            <th>Ingredient</th>
            <th>Price</th>
            <th style={{ width: "200px" }}></th>
          </tr>
        </thead>
        <tbody>
          {props.ingredients.map((ing) => (
            <tr key={ing.id}>
              <td>{ing.name}</td>
              <td>{formatPrice(ing.price)}</td>
              <td>
                <div className="flex">
                  <button
                    className="btn btn-neutral"
                    onClick={() => buyIngredient(ing.id)}
                  >
                    Buy
                  </button>

                  <button className="btn btn-neutral ml-2">Sell</button>
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
