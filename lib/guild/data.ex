defmodule Guild.Data do
  defstruct guild_id: nil, default_channel: nil

  def new(guild_id) do
    %Guild.Data{guild_id: guild_id}
  end

  def set_channel(%Guild.Data{} = guild) do
    default_channel = Discord.Guild.get_default_channel(guild.guild_id)
    %Guild.Data{ guild | default_channel: default_channel.id}
  end

  def set_channel(%Guild.Data{} = guild, channel_id) do
    %Guild.Data{ guild | default_channel: channel_id}
  end
end
