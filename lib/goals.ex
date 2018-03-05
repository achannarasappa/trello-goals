defmodule Goals do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Goals.Scheduler, [])
    ]

    opts = [strategy: :one_for_one, name: Goals.Supervisor]

    Supervisor.start_link(children, opts)
  end
end