defmodule Guild.Supervisor do
  use DynamicSupervisor
  def init(_args) do
    DynamicSupervisor.init(
      strategy: :one_for_one
    )
  end

  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def start_child(guild_id) do
    {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, {Guild.Process, Guild.Data.new(guild_id)})
    pid
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end
end
