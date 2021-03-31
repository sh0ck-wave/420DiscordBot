defmodule Guild.Data do
  defstruct guild_id: nil, default_channel_id: nil, role_mention: ""

  def new(guild_id) do
    %Guild.Data{guild_id: guild_id}
  end

  def set_initial_channel(%Guild.Data{} = guild) do
    default_channel = Discord.Guild.get_default_channel(guild.guild_id)
    %Guild.Data{ guild | default_channel_id: default_channel.id}
  end

  def set_channel_by_name(%Guild.Data{} = guild, channel_name) do
    %Alchemy.Channel.TextChannel{id: channel_id} = Discord.Guild.get_channel(guild.guild_id, channel_name)
    set_channel_id(guild, channel_id)
  end

  def set_channel_id(%Guild.Data{} = guild, channel_id) do
    %Guild.Data{ guild | default_channel_id: channel_id}
  end

  def set_role_mention(%Guild.Data{} = guild, role) do
    %Guild.Data{ guild | role_mention: role}
  end

  def get_channel(%Guild.Data{} = guild) do
    {:ok, channel} = Alchemy.Client.get_channel(guild.default_channel_id)
    channel
  end

  def get_channel_id(%Guild.Data{default_channel_id: channel_id}), do: channel_id

  def get_role_mention(%Guild.Data{role_mention: role_mention}), do: role_mention

end
