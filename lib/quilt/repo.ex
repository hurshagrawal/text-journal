defmodule Quilt.Repo do
  use Ecto.Repo,
    otp_app: :quilt,
    adapter: Ecto.Adapters.Postgres
end
