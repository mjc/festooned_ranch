defmodule FestoonedRanchTest do
  use ExUnit.Case
  doctest FestoonedRanch

  alias FestoonedRanch.Client

  setup_all do
    ref = :festooned
    {:ok, _listener_pid} = FestoonedRanch.start_listener(ref)
    {:ok, client} = FestoonedRanch.start_client()

    [server_connection] = :ranch.procs(ref, :connections)

    [ref: ref, client: client, server: server_connection]
  end

  test "have client send to server over TCP", %{client: client, server: server} do
    :erlang.trace(server, true, [:receive])

    assert :ok = Client.send(client, "from client to server")
    assert_receive {:trace, ^server, :receive, {:tcp, _port, "from client to server"}}
  end

  @tag :skip
  test "send from server to client over TCP", %{client: client, server: server} do
    :erlang.trace(client, true, [:receive])

    :gen_tcp.controlling_process(client, self())


    assert :ok = GenServer.call(server, "from server to client")
    assert_receive {:trace, ^server, :receive, {:tcp, _port, "from server to client"}}
  end
end
