import React from "react"

function formatPrice(cents) {
  return (cents / 100).toFixed(2)
}

function Market(props) {
  console.log(`props`, props)
  return (
    <div>
      <table>
        <thead>
          <tr>
            <th>Ingredient</th>
            <th>Price</th>
            <th></th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {props.ingredients.map((ing) => (
            <tr>
              <td>{ing.name}</td>
              <td>{formatPrice(ing.price)}</td>
              <td>
                <button>Buy</button>
              </td>
              <td>
                <button>Sell</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

export default Market
