defmodule Cron.Time do
  defstruct hour: nil, minute: nil

  def get_cron_time(timezone) do
    time_now = Timex.now(timezone)
    utc_now = Timex.now()
    utc_trigger = cond do
      time_now.hour <= 4 and time_now.minute < 20 -> Timex.shift(utc_now, hours: 4 - time_now.hour, minutes: 20 - time_now.minute)
      time_now.hour <= 16 and time_now.minute < 20 -> Timex.shift(utc_now, hours: 16 - time_now.hour, minutes: 20 - time_now.minute)
      true -> Timex.shift(utc_now, hours: 24 - time_now.hour + 4, minutes: 20 - time_now.minute)
    end
    %Cron.Time{hour: utc_trigger.hour, minute: utc_trigger.minute}
  end
end

defmodule Cron.Entry do
  defstruct time: nil, user: nil
end



defmodule Cron.Data do
  defstruct time_map: %{}

  def add_user(%Cron.Data{} = cron_data, %User.Data{} = user) do
    cron_time = Cron.Time.get_cron_time(user.timezone)
    keys = [
      Access.key(cron_time, %{}),
      Access.key(user.id, nil)
    ]
    update_in(cron_data, keys, fn _ -> %Cron.Entry{} end)
  end
end
