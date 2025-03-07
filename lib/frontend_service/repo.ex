defmodule FrontendService.Repo do
  use Ecto.Repo,
    otp_app: :frontend_service,
    adapter: Ecto.Adapters.Postgres
end
