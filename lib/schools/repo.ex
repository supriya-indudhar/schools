defmodule Schools.Repo do
  use Ecto.Repo,
    otp_app: :schools,
    adapter: Ecto.Adapters.Postgres
end
