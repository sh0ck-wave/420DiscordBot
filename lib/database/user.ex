defmodule Database.User do
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

  defp filename(db_folder, %User.Id{guild_id: guild_id, user_id: user_id}) do
    "#{db_folder}/#{guild_id}_#{user_id}"
  end

  def handle_cast({:store, %User.Data{} = user}, db_folder) do
    filename(db_folder, user.id)
    |> File.write!(:erlang.term_to_binary(user))
    {:noreply, db_folder}
  end

  def handle_call({:get, %User.Id{} = user_id}, _from, db_folder) do
    data = case File.read(filename(db_folder, user_id)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end
    {:reply, data, db_folder}
  end

  def store(%User.Data{} = user) do
    GenServer.cast(__MODULE__, {:store, user})
  end

  def get(%User.Id{} = user_id) do
    GenServer.call(__MODULE__, {:get, user_id})
  end
end
