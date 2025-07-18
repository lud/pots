import React from "react"
import { router } from "@inertiajs/react"
import { formatPrice } from "../utils"

// TODO we need to use regular ajax here so we do not add the called route into
// the browser history. We should fetch() and router.reload() with preserve
// scroll.
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
        <div className="stats stats-horizontal shadow mt-4">
          <div className="stat">
            <div className="stat-title">Your Wealth</div>
            <div className="stat-value text-primary">
              {formatPrice(props.wealth)}
            </div>
          </div>
          <div className="stat">
            <div className="stat-title">Known Recipes</div>
            <div className="stat-value">{props.known_recipes.length}</div>
          </div>
        </div>
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
                      <div className="text-sm mb-2">
                        <span className="font-medium">Sells for:</span>{" "}
                        <span className="font-mono text-success font-semibold">
                          {formatPrice(recipe.price)}
                        </span>
                      </div>
                      <div className="text-xs opacity-60">
                        <span className="font-medium">
                          Required ingredients:
                        </span>
                        <ul className="list-disc list-inside mt-1 space-y-1">
                          {recipe.components.map((component, index) => (
                            <li key={index}>
                              {component.amount}× Ingredient #{component.id}
                            </li>
                          ))}
                        </ul>
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
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              className="stroke-info shrink-0 w-6 h-6"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              ></path>
            </svg>
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
