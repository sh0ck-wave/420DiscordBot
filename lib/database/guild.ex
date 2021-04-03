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
    |> File.write!(:erlang.term_to_binary(Map.merge(%Guild.Data{}, guild)))
    {:noreply, db_folder}
  end

  def handle_call({:get, guild_id}, _from, db_folder) do
    IO.puts("Loading guild #{guild_id}")
    case File.read(filename(db_folder, guild_id)) do
      {:ok, contents} -> {:reply, Map.merge(%Guild.Data{}, :erlang.binary_to_term(contents)), db_folder}
      _ -> {:reply, nil, db_folder}
    end
  end

  def store(%Guild.Data{} = guild) do
    GenServer.cast(__MODULE__, {:store, guild})
  end

  def get(guild_id) do
    GenServer.call(__MODULE__, {:get, guild_id})
  end

end
