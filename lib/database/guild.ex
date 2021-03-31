defmodule Database.Guild do
  use GenServer

  def init(db_folder) do
    File.mkdir_p(db_folder)
    {:ok, db_folder}
  end

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: __MODULE__)
  end

  def start_link(db_folder) do
    GenServer.start_link(__MODULE__, db_folder, name: __MODULE__)
  end

  defp filename(db_folder, guild_id) do
    "#{db_folder}/#{guild_id}"
  end

  def handle_cast({:store, %Guild.Data{} = guild}, db_folder) do
    filename(db_folder, guild.guild_id)
    |> File.write!(:erlang.term_to_binary(guild))
    {:noreply, db_folder}
  end

  def handle_call({:get, guild_id}, _from, db_folder) do
    data = case File.read(filename(db_folder, guild_id)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end
    {:reply, data, db_folder}
  end

  def store(%Guild.Data{} = guild) do
    GenServer.cast(__MODULE__, {:store, guild})
  end

  def get(guild_id) do
    GenServer.call(__MODULE__, {:get, guild_id})
  end

end
