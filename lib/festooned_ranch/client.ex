defmodule FestoonedRanch.Client do
  use GenServer

  @impl true
  def init(%{ip: ip, port: port} = state) do
    # this should be in a callback and used like connect/0 below.
    # I have not done that here because I don't feel like making the tests
    # any harder to read.

    # {:packet, 2} here prepends a big-endian length header to the data you send.
    {:ok, socket} = :gen_tcp.connect(ip, port, [:binary, :inet, active: true])
    :inet.setopts(socket, [{:packet, 2}])
    :gen_tcp.controlling_process(socket, self())

    {:ok, Map.put(state, :socket, socket)}
  end

  def start_link(default) when is_map(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def handle_info(:connect, %{ip: ip, port: port} = state) do
    {:ok, socket} = :gen_tcp.connect(ip, port, [:binary, :inet, active: true, packet: 0])
    :gen_tcp.controlling_process(socket, self())

    {:noreply, Map.put(state, :socket, socket)}
  end

  @impl true
  def handle_info({:tcp, _socket, _data}, state) do
    # IO.inspect(data, label: "client got")
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, state), do: {:stop, :normal, state}
  def handle_info({:tcp_error, _}, state), do: {:stop, :normal, state}

  @impl true
  def handle_call({:send, data}, _from, %{socket: socket} = state) do
    {:reply, :gen_tcp.send(socket, data), state}
  end

  def send(pid, data) do
    GenServer.call(pid, {:send, data})
  end
end
