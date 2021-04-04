defmodule User.Id do
  defstruct user_id: nil, guild_id: nil

  def create_from_message(%Alchemy.Message{} = message) do
    guild_id = Discord.Message.get_guild_id(message)
    %User.Id{user_id: message.author.id, guild_id: guild_id}
  end
end

defmodule User.Data do
  defstruct id: %User.Id{}, timezone: nil, timer_ref: nil

  def new(%User.Id{} = user_id) do
    %User.Data{id: user_id}
  end

  def create_from_message(%Alchemy.Message{} = message) do
    message
    |> User.Id.create_from_message()
    |> new()
  end

  def set_timezone(%User.Data{} = user, timezone) do
    case Tzdata.canonical_zone?(timezone) do
      true -> {:ok, %User.Data{ user | timezone: timezone }}
      false -> {:error, user}
    end
  end

  def remove_timezone(%User.Data{} = user) do
    cancel_timer_ref(user)
    %User.Data{user | timezone: nil, timer_ref: nil}
  end

  defp cancel_timer_ref(%User.Data{timer_ref: nil}) do
    :ok
  end

  defp cancel_timer_ref(%User.Data{timer_ref: timer_ref, id: user_id}) do
    IO.puts("Started cancelling old timer for #{user_id.user_id}")
    case Process.read_timer(timer_ref) do
      false -> :ok
      _ -> Process.cancel_timer(timer_ref, async: true, info: false)
    end
    IO.puts("Finished cancelling old timer for #{user_id.user_id}")
  end

  def set_timer(%User.Data{timezone: nil} = user, _) do
    %User.Data{ user | timer_ref: nil}
  end

  def set_timer(%User.Data{} = user, user_proc) do
    new_timer = Process.send_after(user_proc, :notification_event, TimeCalculations.get_ms_to_420(user.timezone))
    IO.puts("Created timer for #{user.id.user_id}")
    cancel_timer_ref(user)
    %User.Data{ user | timer_ref: new_timer}
  end

  def get_timezone(%User.Data{timezone: tz}) do
    tz
  end
end
