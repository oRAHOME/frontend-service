defmodule FrontendService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FrontendServiceWeb.Telemetry,
      FrontendService.Repo,
      {DNSCluster, query: Application.get_env(:frontend_service, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FrontendService.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: FrontendService.Finch},
      # Start a worker by calling: FrontendService.Worker.start_link(arg)
      # {FrontendService.Worker, arg},
      # Start to serve requests, typically the last entry
      FrontendServiceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FrontendService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FrontendServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
