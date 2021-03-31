defmodule Discord.Guild do
  alias Alchemy.Client

  def get_channel(guild_id, channel_name) do
    {:ok, channels} = Client.get_channels(guild_id)
    [%Alchemy.Channel.TextChannel{} = match | _] = channels
    |> Enum.filter(fn ch -> ch.name == channel_name end)
    match
  end

  defp is_text_channel(channel) do
    case channel do
      %Alchemy.Channel.TextChannel{} -> true
      _ -> false
    end
  end

  def get_default_channel(guild_id) do
    {:ok, channels} = Client.get_channels(guild_id)
    channels
    |> Stream.filter(&is_text_channel/1)
    |> Enum.min_by(fn ch -> ch.position || 100 end)
  end

end
