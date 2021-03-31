defmodule Discord.Message do
  alias Alchemy.Client

  def get_guild_id(%Alchemy.Message{} = message) do
    {:ok, channel} = Client.get_channel(message.channel_id)
    channel.guild_id
  end

end
