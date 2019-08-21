defmodule ClubHomepage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      ClubHomepage.Repo,
      # Start the endpoint when the application starts
      ClubHomepageWeb.Endpoint,
      # Starts a worker by calling: Hello.Worker.start_link(arg)
      # {Hello.Worker, arg},
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ClubHomepage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ClubHomepageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
