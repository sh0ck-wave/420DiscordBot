defmodule TimeCalculations do

  defp seconds_to_ms(seconds), do: seconds * 1000
  defp minutes_to_ms(minutes), do: minutes * 60 |> seconds_to_ms()
  defp hours_to_ms(hours), do: hours * 60 |> minutes_to_ms()

  def get_ms_to_420(timezone) do
    time_now = Timex.now(timezone)
    cond do
      (time_now.hour < 4) or (time_now.hour == 4 and time_now.minute <= 20) -> hours_to_ms(4 - time_now.hour) +  minutes_to_ms(20 - time_now.minute)
      (time_now.hour < 16) or (time_now.hour == 16 and time_now.minute <= 20) -> hours_to_ms(16 - time_now.hour) +  minutes_to_ms(20 - time_now.minute)
      true -> hours_to_ms(24 - time_now.hour + 4) + minutes_to_ms(20 - time_now.minute)
    end
  end
end
