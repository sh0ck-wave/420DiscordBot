defmodule Bot do
  use Application
  alias Alchemy.Client

  defmodule Commands do
    use Alchemy.Cogs
    alias Alchemy.Embed
    require Alchemy.Embed
    alias Discord.Message

    Cogs.def ping do
      Cogs.say("pong!")
    end

    defp get_user_proc(%Alchemy.Message{} = message) do
      user_id = User.Id.create_from_message(message)
      User.Cache.get_user_process(user_id)
    end

    Cogs.def gettz do
      tz = get_user_proc(message)
      |> User.Process.get_user_state
      |> User.Data.get_timezone
      Cogs.say("#{tz || "No Timezone set"}")
    end

    Cogs.def removetz do
      user_proc = get_user_proc(message)
      User.Process.remove_timezone(user_proc)
      Cogs.say("Timezone cleared")
    end

    Cogs.def help() do
      %Embed{}
      |> Embed.title("Commands")
      |> Embed.description("""
        **User Commands**
        `settz` : set your timezone
        `gettz` : get your timezone
        `removetz` : remove your timezone
        `getchannel` : gets the channel to which notification message will be sent
        `getrole` : gets the role which will be notified in the message

        **Admin Commands**
        `setchannel` : set the notification channel
        `setrole` : set the notification role
        `mute` : mute the bot
        `unmute` : unmute the bot
        `test` : send a test notification for the current user
      """)
      |> Embed.send()
    end


    Cogs.def settz() do
      %Embed{}
      |> Embed.title("Set your timezone")
      |> Embed.description("""
        You can get the timezone name from [here](https://kevinnovak.github.io/Time-Zone-Picker/)
        Enter your timezone name or 'stop' to cancel
      """)
      |> Embed.send()

      user_proc = get_user_proc(message)
      Cogs.wait_for :message, fn msg -> message.author.id == msg.author.id end, fn msg ->
        case msg.content do
          "stop" -> "Stopped"
          content ->
            case User.Process.set_timezone(user_proc, content) do
              :ok -> "Timezone Set"
              :error -> "Timezone Invalid"
            end
        end
        |> Cogs.say
      end
    end

    Cogs.def getchannel() do
      %Alchemy.Channel.TextChannel{name: channel_name} = Message.get_guild_id(message)
      |> Guild.Cache.get_guild_process
      |> Guild.Process.get_channel()
      Cogs.say("##{channel_name}")
    end

    Cogs.def getrole() do
      %Guild.Data{role_mention: role} = Message.get_guild_id(message)
      |> Guild.Cache.get_guild_process
      |> Guild.Process.get_guild_state()
      Cogs.say("#{role}")
    end

    Cogs.def setchannel(channel_name) do
      role_gaurd(message, fn ->
        Message.get_guild_id(message)
        |> Guild.Cache.get_guild_process
        |> Guild.Process.set_channel_name(channel_name)
      end)
    end

    Cogs.def test do
      role_gaurd(message, fn ->
        user_proc = get_user_proc(message)
        send(user_proc, :notification_event)
      end)
    end


    Cogs.def mute do
      role_gaurd(message, fn ->
        Message.get_guild_id(message)
        |> Guild.Cache.get_guild_process
        |> Guild.Process.set_muted(true)
        Cogs.say("420 bot has been muted")
      end)
    end

    Cogs.def unmute do
      role_gaurd(message, fn ->
        Message.get_guild_id(message)
        |> Guild.Cache.get_guild_process
        |> Guild.Process.set_muted(false)
        Cogs.say("420 bot has been unmuted")
      end)
    end

    Cogs.def setrole(role_name) do
      role_gaurd(message, fn ->
        Message.get_guild_id(message)
        |> Guild.Cache.get_guild_process
        |> Guild.Process.set_role_mention(role_name)
        Cogs.say("Role has been set to #{role_name}")
      end)
    end

    defp role_gaurd(message, command_function) do
      case has_admin_role?(message) do
        true ->
          command_function.()
        false ->
          Cogs.say("Only members with @420admin role can use this command")
      end
    end

    defp has_admin_role?(message) do
      {:ok, guild_id} = Cogs.guild_id()
      {:ok, guild} = Client.get_guild(guild_id)
      case Enum.find(guild.roles, nil, fn role -> role.name == "420admin" end) do
        nil -> false
        admin_role ->
          {:ok, member} = Client.get_member(guild_id, message.author.id)
          Enum.member?(member.roles, admin_role.id)
      end
    end

    def set_prefix do
      Cogs.set_prefix("~")
    end
  end

  def start(_type, _args) do
    RootSupervisor.start_link()
    spawn(fn ->
      User.Loader.run("data_store/users")
    end)




    run = Client.start("")
    Commands.set_prefix()
    use Commands
    run
  end
end
