run: deps
  iex -S mix phx.server

migrate:
  mix ecto.setup
  mix ecto.migrate

deps:
  mix deps.get