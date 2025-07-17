import React, { useEffect, useState } from "react"
import { Link, usePage } from "@inertiajs/react"
import { router } from "@inertiajs/react"

router.on("error", (errorEvent) => {
  // inertial uses a map for errors (plural)
  // we use the map as a message holder so it's a single error
  const { message } = errorEvent.detail?.errors

  console.error(`message`, message)
})

export default function Layout({ children }) {
  const page = usePage()
  console.log(`pageProps`, page.props)
  const [wealth, setWealth] = useState(0)
  useEffect(() => {
    if (typeof page.props.wealth === "number") {
      setWealth(page.props.wealth)
    }
  }, [page.props.wealth])

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
