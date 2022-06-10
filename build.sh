#!/usr/bin/env bash
#https://sergiotapia.com/phoenix-160-liveview-esbuild-tailwind-jit-alpinejs-a-brief-tutorial
# exit on error
set -o errexit

# Install deps
npm install --prefix ./assets
mix deps.get --only prod

# Initial setup
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix compile

# Migrate the database
MIX_ENV=prod mix ecto.migrate

# Build the release and overwrite the existing release directory
MIX_ENV=prod mix release --overwrite

