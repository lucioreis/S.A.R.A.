#!/bin/zsh
mix ecto.drop
mix ecto.create
mix ecto.migrate
# mix run ./priv/repo/seeds.exs
