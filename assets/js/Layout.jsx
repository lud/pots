import React, { useEffect, useState } from "react"
import { Link, usePage } from "@inertiajs/react"
import { router } from "@inertiajs/react"
import { Toaster, toast } from "react-hot-toast"

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
  const page = usePage()
  console.log(`pageProps`, page.props)
  const [wealth, setWealth] = useState(0)

  /**
   * @typedef {Object} ToastData — documentation for isLoading
   * @property {"error" | "success" | "info" | "warning"} level
   * @property {string} message
   */
  /**
   * @typedef {Function} LoadingStateSetter — documentation for setIsLoading
   */
  /**
   * @type {[ToastData[], LoadingStateSetter]} Loading
   */
  const [toasts, setToasts] = useState([])

  useEffect(() => {}, [])

  useEffect(() => {
    if (typeof page.props.wealth === "number") {
      setWealth(page.props.wealth)
    }
  }, [page.props.wealth])

  return (
    <main>
      <Toaster toastOptions={{ duration: 1000 }} />
      <header>
        {/* <Link href="/">Home</Link>
        <Link href="/about">About</Link>
        <Link href="/contact">Contact</Link> */}
        <span>{wealth.toFixed(2)} $</span>
      </header>
      <div>{children}</div>
    </main>
  )
}
