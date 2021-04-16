defmodule Discord.Message do
  alias Alchemy.Client

  def get_guild_id(%Alchemy.Message{} = message) do
    {:ok, channel} = Client.get_channel(message.channel_id)
    channel.guild_id
  end

  def send_420_message(%User.Data{id: %User.Id{guild_id: guild_id, user_id: user_id}}) do
    guild_id
    |> Guild.Cache.get_guild_process()
    |> Guild.Process.get_guild_state()
    |> send_message(user_id)
  end

  defp send_message(%Guild.Data{default_channel_id: channel_id, muted: true}, username) do
    IO.puts("Not sending message to #{channel_id} for #{username} since guild is muted")
  end

  defp send_message(%Guild.Data{default_channel_id: channel_id, role_mention: role_name, muted: false}, user_id) do
    {:ok, %Alchemy.User{username: username} = user} = Client.get_user(user_id)
    mention = case role_name do
      "" -> Alchemy.User.mention(user)
      nil -> Alchemy.User.mention(user)
      _ -> role_name
    end


      role_name || Alchemy.User.mention(user)
    IO.puts("Started sending Message to #{channel_id} for #{username}")
    Client.send_message(channel_id, "#{mention} Its 4:20 for #{username}!!")
    IO.puts("Finished sending Message to #{channel_id} for #{username}")
  end

end
