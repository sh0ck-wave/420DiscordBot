
defmodule User.Supervisor do
  use DynamicSupervisor

  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one
    )
  end

  def start_child(%User.Id{} = user_id) do
    {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, {User.Process, user_id})
    pid
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

end
