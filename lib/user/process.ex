defmodule User.Process do
  use GenServer, restart: :temporary

  def init(user) do
    {:ok, user || %User.Data{}}
  end

  def start_link(%User.Id{} = user_id) do
    GenServer.start_link(__MODULE__, User.Data.new(user_id), name: via_tuple(user_id))
  end

  def handle_call({:get_timezone}, _from, %User.Data{}=user) do
    tz = User.Data.get_timezone(user)
    {:reply, tz, user}
  end

  def handle_call({:set_timezone, timezone}, _from, %User.Data{}=user) do
    {result, user} = User.Data.set_timezone(user, timezone)
    {:reply, result, user}
  end

  defp via_tuple(%User.Id{}=user_id) do
    {:via, Registry, {:user_registry, user_id}}
  end

  def set_timezone(user_proc, timezone) do
    GenServer.call(user_proc, {:set_timezone, timezone})
  end

  def get_timezone(user_proc) do
    GenServer.call(user_proc, {:get_timezone})
  end

  # def child_spec(%User.Id} = user_id) do
  #   %{
  #     id: __MODULE__,
  #     start: {__MODULE__, :start_link, [user_id]}
  #   }
  # end

  # def child_spec(%User.Data{} = user) do
  #   %{
  #    id: __MODULE__,
  #    start: {__MODULE__, :start_link, [user]}
  #   }
  # end
end
