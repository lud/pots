import React, { useEffect, useState } from "react"
import { Link, usePage } from "@inertiajs/react"
import { router } from "@inertiajs/react"
import { Toaster, toast } from "react-hot-toast"
import { formatPrice, usePropMemo } from "./utils"

router.on("error", (errorEvent) => {
  // inertial uses a map for errors (plural)
  // we use the map as a message holder so it's a single error
  const { message } = errorEvent.detail?.errors
  toast.custom((t) => (
    <div role="alert" className="alert alert-error">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        className="h-6 w-6 shrink-0 stroke-current"
        fill="none"
        viewBox="0 0 24 24"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth="2"
          d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
        />
      </svg>
      <span>{message}</span>
    </div>
  ))
})

export default function Layout({ children }) {
  console.log(`pageProps`, usePage())
  const wealth = usePropMemo("wealth", 0)

  return (
    <main>
      <Toaster toastOptions={{ duration: 1000 }} />
      <header className="navbar bg-base-100 shadow-lg">
        <div className="navbar-start">
          <div className="dropdown">
            <div tabIndex={0} role="button" className="btn btn-ghost lg:hidden">
              <svg
                className="w-5 h-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M4 6h16M4 12h8m-8 6h16"
                ></path>
              </svg>
            </div>
            <ul
              tabIndex={0}
              className="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52"
            >
              <MenuLinks />
            </ul>
          </div>
          <Link href="/" className="btn btn-ghost text-xl">
            Potions
          </Link>
        </div>
        <div className="navbar-center hidden lg:flex">
          <ul className="menu menu-horizontal px-1">
            <MenuLinks />
          </ul>
        </div>
        <div className="navbar-end">
          <span className="font-mono text-lg font-bold">
            {formatPrice(wealth)} $
          </span>
        </div>
      </header>
      <div className="container mx-auto p-4">{children}</div>
    </main>
  )
}

function MenuLinks() {
  return (
    <>
      <li>
        <Link href="/laboratory">Laboratory</Link>
      </li>
      <li>
        <Link href="/market">Market</Link>
      </li>
      <li>
        <Link href="/bookshop">Book Shop</Link>
      </li>
    </>
  )
}
