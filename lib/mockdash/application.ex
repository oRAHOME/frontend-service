defmodule Mockdash.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MockdashWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:mockdash, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Mockdash.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Mockdash.Finch},
      # Start a worker by calling: Mockdash.Worker.start_link(arg)
      # {Mockdash.Worker, arg},
      # Start to serve requests, typically the last entry
      MockdashWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mockdash.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MockdashWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
