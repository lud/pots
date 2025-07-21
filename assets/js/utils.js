import { usePage } from "@inertiajs/react"
import { useEffect, useState } from "react"

export function formatPrice(price) {
  return price.toFixed(2)
}

/**
 * @param {unknown} initValue
 */
export function usePropMemo(key, initValue = void 0) {
  const page = usePage()
  const [value, setValue] = useState(initValue)

  useEffect(
    () => {
      if (typeof page.props[key] !== "undefined" && null !== page.props[key]) {
        setValue(page.props[key])
      }
    },
    [page.props[key]]
  )

  return value
}