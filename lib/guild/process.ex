defmodule Guild.Process do
  use GenServer

  def init(guild_id) do
    send(self(), :load)
    {:ok, Guild.Data.new(guild_id)}
  end

  def start_link(guild_id) do
    GenServer.start_link(__MODULE__, guild_id, name: via_tuple(guild_id))
  end

  defp via_tuple(guild_id) do
    {:via, Registry, {:guild_registry, guild_id}}
  end

  def handle_call(:get_channel, _from, %Guild.Data{} = guild) do
    {:reply, Guild.Data.get_channel(guild), guild}
  end

  def handle_call(:get_state, _from, %Guild.Data{} = guild) do
    {:reply, guild, guild}
  end

  def handle_info(:load, %Guild.Data{} = guild) do
    case Database.Guild.get(guild.guild_id) do
      nil ->  {:noreply,  Guild.Data.set_initial_channel(guild)}
      guild_from_disk -> {:noreply, guild_from_disk}
    end
  end

  def handle_cast({:set_role_mention, role}, %Guild.Data{} = guild) do
    new_guild = Guild.Data.set_role_mention(guild, role)
    Database.Guild.store(new_guild)
    {:noreply,  new_guild}
  end

  def handle_cast({:set_channel_name, channel_name}, %Guild.Data{} = guild) do
    new_guild = Guild.Data.set_channel_by_name(guild, channel_name)
    Database.Guild.store(new_guild)
    {:noreply,  new_guild}
  end

  def set_channel_name(guild_proc, channel_name) do
    GenServer.cast(guild_proc, {:set_channel_name, channel_name})
  end

  def set_role_mention(guild_proc, role) do
    GenServer.cast(guild_proc, {:set_role_mention, role})
  end

  def get_channel(guild_proc) do
    GenServer.call(guild_proc, :get_channel)
  end

  def get_guild_state(guild_proc) do
    GenServer.call(guild_proc, :get_state)
  end
end
