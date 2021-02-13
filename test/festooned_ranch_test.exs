defmodule FestoonedRanchTest do
  use ExUnit.Case
  doctest FestoonedRanch

  alias FestoonedRanch.Client
  alias FestoonedRanch.Protocol

  setup_all do
    ref = :festooned
    {:ok, _listener_pid} = FestoonedRanch.start_listener(ref)
    {:ok, client} = FestoonedRanch.start_client()

    [server_connection] = :ranch.procs(ref, :connections)

    [ref: ref, client: client, server: server_connection]
  end

  test "have client send to server over TCP", %{client: client, server: server} do
    :erlang.trace(server, true, [:receive])

    assert :ok = Client.send(client, "from client to server\n")
    assert_receive {:trace, ^server, :receive, {:tcp, _port, "from client to server\n"}}
  end

  test "send from server to client over TCP", %{ref: ref, client: client} do
    :erlang.trace(client, true, [:receive])

    assert :ok = Protocol.send(ref, "from server to client\n")
    assert_receive {:trace, ^client, :receive, {:tcp, _port, "from server to client\n"}}
  end
end
