defmodule Sapiens.Repo do
  use Ecto.Repo,
    otp_app: :sapiens,
    adapter: Ecto.Adapters.Postgres

end
