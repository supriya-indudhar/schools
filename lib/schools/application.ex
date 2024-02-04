defmodule Schools.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Schools.Repo
      # Starts a worker by calling: Schools.Worker.start_link(arg)
      # {Schools.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Schools.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
