defmodule RootSupervisor do
  use Supervisor

  def init(_args) do
    children = [
      {Registry, name: :user_registry, keys: :unique},
      {Database.Guild, ["data_store/guilds"]},
      {Database.User, ["data_store/users"]},
      {User.Supervisor, []},
      {User.Cache, []},
      {Registry, name: :guild_registry, keys: :unique},
      {Guild.Supervisor, []},
      {Guild.Cache, []},
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end
end
