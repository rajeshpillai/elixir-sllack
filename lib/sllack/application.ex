defmodule Sllack.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SllackWeb.Telemetry,
      Sllack.Repo,
      {DNSCluster, query: Application.get_env(:sllack, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Sllack.PubSub},
      # Start a worker by calling: Sllack.Worker.start_link(arg)
      # {Sllack.Worker, arg},
      # Start to serve requests, typically the last entry
      SllackWeb.Presence, # this is needed before Endpoint (TODO: need to verify)
      SllackWeb.Endpoint,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sllack.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SllackWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
