defmodule FestoonedRanch do
  def start_listener(ref) do
    :ranch.start_listener(ref, :ranch_tcp, [port: 5555], FestoonedRanch.Protocol, [])
  end

  def start_client(ip \\ {127, 0, 0, 1}, port \\ 5555) do
    FestoonedRanch.Client.start_link(%{ip: ip, port: port})
  end
end
