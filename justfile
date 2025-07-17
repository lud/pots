run: deps
  iex -S mix phx.server

deps:
  mix deps.get

migrate:
    mix ecto.setup
    MIX_ENV=test mix ecto.setup

reset-db-test:
    MIX_ENV=test mix ecto.drop --force
    MIX_ENV=test mix ecto.setup

# Rollbacks and re run all migrations for the development database
# reset-db-dev: _confirm
reset-db-dev:
    mix ecto.drop --force
    mix ecto.setup

# Reset the development and test databases
reset-db-all: reset-db-dev reset-db-test

_confirm prompt='Are you sure?':
    #!/usr/bin/env bash
    read -p "{{prompt}} [y/N] " -r
    if [[ ! $REPLY =~ ^(Y|y)$ ]]
    then
        echo # newline
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
    else
        echo # newline
    fi

