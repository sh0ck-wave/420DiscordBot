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
      Cogs.say("#{tz}")
    end

    Cogs.def removetz do
      user_proc = get_user_proc(message)
      User.Process.remove_timezone(user_proc)
      Cogs.say("Timezone cleared")
    end

    Cogs.def settz do
      %Embed{}
      |> Embed.title("Set your timezone")
      |> Embed.description("""
        You can get the timezone name from [here](https://kevinnovak.github.io/Time-Zone-Picker/)
        Enter your timezone name or 'stop' to cancel
      """)
      |> Embed.send()

      user_proc = get_user_proc(message)
      Cogs.wait_for :message, fn msg ->
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
      IO.inspect(channel_name)
      Cogs.say("##{channel_name}")
    end

    Cogs.def setchannel(channel_name) do
      Message.get_guild_id(message)
      |> Guild.Cache.get_guild_process
      |> Guild.Process.set_channel_name(channel_name)
    end

    Cogs.def setrole(role_name) do
      Message.get_guild_id(message)
      |> Guild.Cache.get_guild_process
      |> Guild.Process.set_role_mention(role_name)
    end

    Cogs.def test do
      user_proc = get_user_proc(message)
      send(user_proc, :notification_event)
    end

    def set_prefix do
      Cogs.set_prefix("~")
    end
  end

  def start(_type, _args) do
    RootSupervisor.start_link()
    User.Loader.start_link("data_store/users")



    run = Client.start("")
    Commands.set_prefix()
    use Commands
    run
  end
end
