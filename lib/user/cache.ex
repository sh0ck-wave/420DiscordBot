defmodule User.Cache do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_init_arg) do
    {:ok, nil}
  end

  def handle_call({:create, %User.Id{} = user_id}, _from, user) do
    pid = Registry.lookup(:user_registry, user_id)
    |> case do
      [] -> User.Supervisor.start_child(user_id)
      [{p, _}] -> p
    end
    {:reply, pid, user}
  end

  def get_user_process(%User.Id{} = user_id) do
    Registry.lookup(:user_registry, user_id)
    |> case do
      [] -> GenServer.call(__MODULE__, {:create, user_id})
      [{p, _}] -> p
    end
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

end
