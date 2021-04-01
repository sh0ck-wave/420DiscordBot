defmodule User.Loader do
  use Task, restart: :temporary

  def init(_args) do
    {:ok, nil}
  end

  def start_link(user_db_folder) do
    Task.start_link(__MODULE__, :run, [user_db_folder])
  end

  def run(user_db_folder) do
    IO.puts("Starting loading")
    {:ok, files} = File.ls(user_db_folder)
    files
    |> Stream.map(fn fname ->
      [guild_id, user_id] = String.split(fname, "_")
      %User.Id{user_id: user_id, guild_id: guild_id}
    end)
    |> Enum.map(fn user_id ->
      User.Cache.create_user_process_async(user_id)
    end)
  end

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end
end
