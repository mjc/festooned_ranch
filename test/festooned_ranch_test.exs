defmodule FestoonedRanchTest do
  use ExUnit.Case
  doctest FestoonedRanch

  test "have client send to server over TCP" do
    ref = :festooned
    assert {:ok, _listener_pid} = FestoonedRanch.start_listener(ref)
    assert {:ok, client_port} = FestoonedRanch.start_client()

    assert [connection] = :ranch.procs(ref, :connections)
    :erlang.trace(connection, true, [:receive])


    assert :ok = :gen_tcp.send(client_port, "bleh")
    assert_receive {:trace, ^connection, :receive, {:tcp, _port, "bleh"}}
  end
end
