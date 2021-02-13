defmodule FestoonedRanch do
  @spec start_link :: {:error, any} | {:ok, :undefined | pid} | {:ok, :undefined | pid, any}
  def start_link() do
    :ranch.start_listener(:festooned, :ranch_tcp, [{:port, 5555}], FestoonedRanch.GenProtocol, [])
  end
end
