defmodule Sllack.Repo do
  use Ecto.Repo,
    otp_app: :sllack,
    adapter: Ecto.Adapters.Postgres
end
