defmodule Guild.Process do
  use GenServer

  def init(%Guild.Data{} = args) do
    {:ok, args}
  end

  def start_link(%Guild.Data{} = guild) do
    GenServer.start_link(__MODULE__, guild, name: via_tuple(guild.guild_id))
  end

  defp via_tuple(guild_id) do
    {:via, Registry, {:guild_registry, guild_id}}
  end

  def handle_cast({:set_channel}, %Guild.Data{} = guild) do
    {:noreply,  Guild.Data.set_channel(guild)}
  end

  def handle_cast({:set_channel, channel_id}, %Guild.Data{} = guild) do
    {:noreply,  Guild.Data.set_channel(guild, channel_id)}
  end

  def handle_cast({:set_channel_name, channel_name}, %Guild.Data{} = guild) do
    %Alchemy.Channel.TextChannel{id: channel_id} = Discord.Guild.get_channel(guild.guild_id, channel_name)
    {:noreply,  Guild.Data.set_channel(guild, channel_id)}
  end

  def set_channel(guild_proc) do
    GenServer.cast(guild_proc, {:set_channel})
  end

  def set_channel_id(guild_proc, channel_id) do
    GenServer.cast(guild_proc, {:set_channel, channel_id})
  end

  def set_channel_name(guild_proc, channel_name) do
    GenServer.cast(guild_proc, {:set_channel_name, channel_name})
  end

end
