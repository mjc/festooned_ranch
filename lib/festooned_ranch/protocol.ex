defmodule FestoonedRanch.Protocol do
  use GenServer

  @behaviour :ranch_protocol

  @impl true
  def start_link(ref, transport, opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [[ref, transport, opts]])
    {:ok, pid}
  end

  @impl true
  def init([ref, transport, opts]) do
    {:ok, socket} = :ranch.handshake(ref, opts)
    # {:packet, 2} here expects a big-endian length at the start of your packet
    # and then it knows how much data to expect
    :ok = :inet.setopts(socket, [{:active, true}, {:packet, 2}])
    :gen_server.enter_loop(__MODULE__, [], %{socket: socket, transport: transport})
  end

  @impl true
  def handle_info({:tcp, socket, data}, %{socket: socket, transport: transport} = state) do
    # IO.inspect(data, label: "server got")
    transport.send(socket, data)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, %{socket: socket, transport: transport} = state) do
    transport.close(socket)
    {:stop, :normal, state}
  end

  @impl true
  def handle_call({:send, data}, _from, %{socket: socket, transport: transport} = state) do
    {:reply, transport.send(socket, data), state}
  end

  def handle_call(:peername, _from, %{socket: socket} = state) do
    {:reply, :inet.peername(socket), state}
  end

  @spec send(any, any) :: any
  def send(ref, data) do
    [first_connection] = :ranch.procs(ref, :connections)
    GenServer.call(first_connection, {:send, data})
  end

  def peernames(ref) do
    connections = :ranch.procs(ref, :connections)

    Enum.map(connections, fn conn ->
      {:ok, {ip, port}} = GenServer.call(conn, :peername)
      {ip, port}
    end)
  end
end
