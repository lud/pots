import React, { useState } from "react"
import { Link, usePage } from "@inertiajs/react"

export default function Layout({ children }) {
  const page = usePage()
  console.log(`pageProps`, page.props)
  const [wealth, setWealth] = useState(0)
  if (typeof page.props.wealth === "number") {
    setWealth(page.props.wealth)
  }
  return (
    <main>
      <header>
        {/* <Link href="/">Home</Link>
        <Link href="/about">About</Link>
        <Link href="/contact">Contact</Link> */}
        <span>{wealth.toFixed(2)} $</span>
      </header>
      <article>{children}</article>
    </main>
  )
}
