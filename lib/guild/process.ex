defmodule Guild.Process do
  use GenServer, restart: :temporary

  def init(%Guild.Data{} = args) do
    send(self(), :set_initial_channel)
    {:ok, args}
  end

  def start_link(%Guild.Data{} = guild) do
    GenServer.start_link(__MODULE__, guild, name: via_tuple(guild.guild_id))
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

  def handle_info(:set_initial_channel, %Guild.Data{} = guild) do
    {:noreply,  Guild.Data.set_initial_channel(guild)}
  end

  # def handle_cast({:set_channel_id, channel_id}, %Guild.Data{} = guild) do
  #   {:noreply,  Guild.Data.set_channel_id(guild, channel_id)}
  # end

  def handle_cast({:set_role_mention, role}, %Guild.Data{} = guild) do
    {:noreply,  Guild.Data.set_role_mention(guild, role)}
  end

  def handle_cast({:set_channel_name, channel_name}, %Guild.Data{} = guild) do
    {:noreply,  Guild.Data.set_channel_by_name(guild, channel_name)}
  end

  # def set_channel_id(guild_proc, channel_id) do
  #   GenServer.cast(guild_proc, {:set_channel_id, channel_id})
  # end

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
