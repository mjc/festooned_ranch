defmodule FestoonedRanch.GenProtocol do
  use GenServer

  @behaviour :ranch_protocol

  @impl true
  def start_link(ref, transport, opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [[ref, transport, opts]])
    {:ok, pid}
  end

  @impl true
  def init([ref, transport, opts]) do
    IO.puts "Starting protocol"
    {:ok, socket} = :ranch.handshake(ref, opts)
    :ok = transport.setopts(socket, [{:active, true}])
    :gen_server.enter_loop(__MODULE__, [], %{socket: socket, transport: transport})
  end

  @impl true
  def handle_call(data, _from, %{socket: socket, transport: transport} = state) do
    transport.send(socket, data)
    {:reply, :ok, state}
  end

  @impl true
  def handle_info({:tcp, socket, data}, state = %{socket: socket, transport: transport}) do
    IO.inspect data
    IO.inspect transport
    transport.send(socket, data)
    {:noreply, state}
  end
  def handle_info({:tcp_closed, socket}, state = %{socket: socket, transport: transport}) do
    IO.puts "Closing"
    transport.close(socket)
    {:stop, :normal, state}
  end
end
