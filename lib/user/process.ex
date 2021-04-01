defmodule User.Process do
  use GenServer

  def init(user_id) do
    send(self(), :load)
    {:ok, User.Data.new(user_id)}
  end

  def start_link(%User.Id{} = user_id) do
    GenServer.start_link(__MODULE__, user_id, name: via_tuple(user_id))
  end

  def handle_info(:notification_event, %User.Data{} = user) do
    Discord.Message.send_420_message(user)
    {:noreply, User.Data.set_timer(user, self())}
  end

  def handle_info(:load, %User.Data{} = user) do
    IO.puts("DB Loading user #{user.id.user_id}")
    case Database.User.get(user.id) do
      nil -> {:noreply, user}
      user_from_disk -> {:noreply, User.Data.set_timer(user_from_disk, self())}
    end
  end

  def handle_call({:get_state}, _from, %User.Data{}=user) do
    {:reply, user, user}
  end

  def handle_call({:set_timezone, timezone}, _from, %User.Data{}=user) do
    case User.Data.set_timezone(user, timezone) do
      {:ok, u} ->
        new_user = User.Data.set_timer(u, self())
        Database.User.store(new_user)
        {:reply, :ok, new_user}
      {:error, u} -> {:reply, :error, u}
    end
  end

  def handle_cast(:remove_timezone, %User.Data{}=user) do
    user = User.Data.remove_timezone(user)
    Database.User.store(user)
    {:noreply, user}
  end

  defp via_tuple(%User.Id{}=user_id) do
    {:via, Registry, {:user_registry, user_id}}
  end

  def set_timezone(user_proc, timezone) do
    GenServer.call(user_proc, {:set_timezone, timezone})
  end

  def remove_timezone(user_proc) do
    GenServer.cast(user_proc, :remove_timezone)
  end

  def get_user_state(user_proc) do
    GenServer.call(user_proc, {:get_state})
  end

end
