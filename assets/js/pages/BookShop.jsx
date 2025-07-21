import React from "react"
import { router } from "@inertiajs/react"
import { formatPrice } from "../utils"

function buyBook(id) {
  router.post("/bookshop/buy", {
    id,
  })
}

function BookShop(props) {
  console.log(`BookShop props`, props)

  const canAfford = (price) => props.wealth >= price

  return (
    <div>
      <div className="mb-6">
        <h2 className="text-3xl font-bold">Book Shop</h2>
        <p className="text-base opacity-70 mt-2">
          Discover new recipes by purchasing books
        </p>
      </div>

      {props.books.length > 0 ? (
        <div className="card bg-base-100 shadow-xl">
          <div className="card-body">
            <h3 className="card-title">Available Books</h3>
            <div className="overflow-x-auto">
              <table className="table table-zebra">
                <thead>
                  <tr>
                    <th>Book</th>
                    <th>Recipes</th>
                    <th>Price</th>
                    <th style={{ width: "150px" }}>Action</th>
                  </tr>
                </thead>
                <tbody>
                  {props.books.map((book) => (
                    <tr key={book.id}>
                      <td>
                        <div>
                          <div className="font-medium text-base">
                            {book.name}
                          </div>
                        </div>
                      </td>
                      <td>
                        <span className="badge badge-neutral">
                          {book.n_recipes} recipe
                          {book.n_recipes !== 1 ? "s" : ""}
                        </span>
                      </td>
                      <td>
                        <span className="font-mono text-lg font-semibold">
                          {formatPrice(book.price)}
                        </span>
                      </td>
                      <td>
                        <button
                          className={`btn btn-sm ${
                            canAfford(book.price)
                              ? "btn-primary"
                              : "btn-disabled"
                          }`}
                          onClick={() => buyBook(book.id)}
                          disabled={!canAfford(book.price)}
                        >
                          Buy
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      ) : (
        <div className="hero bg-base-200 rounded-lg">
          <div className="hero-content text-center">
            <div className="max-w-md">
              <h3 className="text-2xl font-bold">All Books Owned!</h3>
              <p className="py-6">
                Congratulations! You've purchased all available books. Check
                your known recipes below to see what you can craft.
              </p>
            </div>
          </div>
        </div>
      )}

      {props.known_recipes.length > 0 && (
        <div className="mt-8">
          <div className="card bg-base-100 shadow-xl">
            <div className="card-body">
              <h3 className="card-title">Your Recipe Collection</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-4">
                {props.known_recipes.map((recipe) => (
                  <div
                    key={recipe.id}
                    className="card bg-base-200 shadow-sm hover:shadow-md transition-shadow"
                  >
                    <div className="card-body p-4">
                      <h4 className="card-title text-base">{recipe.name}</h4>
                      <p className="text-sm opacity-70 mb-2">
                        {recipe.description}
                      </p>

                      <div className="text-xs">
                        <span className="font-medium">Ingredients</span>
                        <ul className="list-disc list-inside mt-1 space-y-1">
                          {recipe.components.map((component, index) => (
                            <li key={index}>
                              {component.amount}× Ingredient #{component.id}
                            </li>
                          ))}
                        </ul>
                      </div>
                      <div className="text-sm mt-2">
                        <span className="font-medium">Sells for: </span>
                        <span className="font-mono text-success-content font-semibold">
                          {formatPrice(recipe.price)}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}

      {props.known_recipes.length === 0 && props.books.length > 0 && (
        <div className="mt-8">
          <div className="alert alert-info">
            <div>
              <h4 className="font-bold">No recipes known yet</h4>
              <p>Purchase books above to learn new potion recipes!</p>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default BookShop
