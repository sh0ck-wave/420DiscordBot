defmodule Guild.Cache do
  use GenServer

  def init(_args) do
    {:ok, nil}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def handle_call({:get_or_create, guild_id}, _from, state) do
    pid = Registry.lookup(:guild_registry, guild_id)
    |> case do
      [] -> Guild.Supervisor.start_child(guild_id)
      [{p, _}] -> p
    end
    {:reply, pid, state}
  end

  def get_guild_process(guild_id) do
    Registry.lookup(:guild_registry, guild_id)
    |> case do
      [] -> GenServer.call(__MODULE__, {:get_or_create, guild_id})
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
