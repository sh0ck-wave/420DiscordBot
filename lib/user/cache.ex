defmodule User.Cache do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_init_arg) do
    {:ok, nil}
  end

  def handle_call({:get_or_create, %User.Id{} = user_id}, _from, state) do
    pid = Registry.lookup(:user_registry, user_id)
    |> case do
      [] ->
        IO.puts("Created #{user_id.user_id}")
        User.Supervisor.start_child(user_id)
      [{p, _}] -> p
    end
    {:reply, pid, state}
  end

  def get_user_process(%User.Id{} = user_id) do
    Registry.lookup(:user_registry, user_id)
    |> case do
      [] -> GenServer.call(__MODULE__, {:get_or_create, user_id})
      [{p, _}] -> p
    end
  end

  def handle_cast({:create, %User.Id{} = user_id}, state) do
    Registry.lookup(:user_registry, user_id)
    |> case do
      [] ->
        IO.puts("Created #{user_id.user_id}")
        User.Supervisor.start_child(user_id)
      [{p, _}] -> p
    end
    {:noreply, state}
  end

  def create_user_process_async(%User.Id{} = user_id) do
    Registry.lookup(:user_registry, user_id)
    |> case do
      [] -> GenServer.cast(__MODULE__, {:create, user_id})
      _ -> :ok
    end
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

end
