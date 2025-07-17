import React from "react"
import axios from "axios"

import { createInertiaApp } from "@inertiajs/react"
import { createRoot } from "react-dom/client"
import Layout from "./Layout"

axios.defaults.xsrfHeaderName = "x-csrf-token"

createInertiaApp({
  resolve: async (name) => {
    const page = await import(`./pages/${name}.jsx`)
    page.default.layout =
      page.default.layout || ((page) => <Layout children={page} />)
    return page
  },
  setup({ App, el, props }) {
    console.log(`App`, App)
    createRoot(el).render(<App {...props} />)
  },
})
