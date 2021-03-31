defmodule Discord420BotTest do
  use ExUnit.Case
  doctest Discord420Bot

  test "greets the world" do
    assert Discord420Bot.hello() == :world
  end
end
