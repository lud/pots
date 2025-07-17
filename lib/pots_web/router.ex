defmodule PotsWeb.Router do
  use PotsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PotsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Inertia.Plug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PotsWeb do
    pipe_through :browser

    # Home page for dev, should redirect to another page
    get "/", MarketController, :index

    scope "/market" do
      get "/", MarketController, :index
      post "/buy", MarketController, :buy
    end

    get "/laboratory", LaboratoryController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PotsWeb do
  #   pipe_through :api
  # end
end
