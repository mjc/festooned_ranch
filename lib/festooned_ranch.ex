defmodule FestoonedRanch do
  def start_listener(ref) do
    :ranch.start_listener(ref, :ranch_tcp, [port: 5555], FestoonedRanch.Protocol, [])
  end

  def start_client() do
    :gen_tcp.connect({127, 0, 0,1}, 5555, [:binary, :inet, active: false, packet: :line])
  end
end
