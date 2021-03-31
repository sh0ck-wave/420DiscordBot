defmodule User.Process do
  use GenServer, restart: :temporary

  def init(user) do
    {:ok, user || %User.Data{}}
  end

  def start_link(%User.Id{} = user_id) do
    GenServer.start_link(__MODULE__, User.Data.new(user_id), name: via_tuple(user_id))
  end

  def handle_info(:notification_event, %User.Data{} = user) do
    Discord.Message.send_420_message(user)
    {:noreply, User.Data.set_timer(user, self())}
  end

  def handle_call({:get_state}, _from, %User.Data{}=user) do
    {:reply, user, user}
  end

  def handle_call({:set_timezone, timezone}, _from, %User.Data{}=user) do
    case User.Data.set_timezone(user, timezone) do
      {:ok, u} -> {:reply, :ok, User.Data.set_timer(u, self())}
      {:error, u} -> {:reply, :error, u}
    end
  end

  defp via_tuple(%User.Id{}=user_id) do
    {:via, Registry, {:user_registry, user_id}}
  end

  def set_timezone(user_proc, timezone) do
    GenServer.call(user_proc, {:set_timezone, timezone})
  end

  def get_user_state(user_proc) do
    GenServer.call(user_proc, {:get_state})
  end

end
