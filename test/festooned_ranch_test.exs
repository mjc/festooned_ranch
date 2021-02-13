defmodule FestoonedRanchTest do
  use ExUnit.Case
  doctest FestoonedRanch

  test "greets the world" do
    assert {:ok, pid} = FestoonedRanch.start_link

  end
end
