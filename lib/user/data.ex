defmodule User.Id do
  defstruct user_id: nil, guild_id: nil

  def create_from_message(%Alchemy.Message{} = message) do
    guild_id = Discord.Message.get_guild_id(message)
    %User.Id{user_id: message.author.id, guild_id: guild_id}
  end

end

defmodule User.Data do
  defstruct id: %User.Id{}, timezone: nil

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

  def get_timezone(%User.Data{timezone: tz}) do
    tz
  end
end
