# Ranch 2.0 demo w/ Elixir GenServer

This demo shows how to use an Elixir GenServer for sending and receiving data via Ranch 2.0.

I made this because existing demos are 1. out of date and 2. don't show how to send data to the GenServer from other processes.

To use:

```
# iex -S mix
```

then:
```
FestoonedRanch.start_link()
```

then in another terminal:

```
# nc localhost 5555
```

This will start an echo server.

To send messages to the `nc` client from `iex`, do this in `iex`:

```
:ranch.procs(:festooned, :connections) |> List.first() |> GenServer.call("moo")
```

`:festooned` is set as the ref passed in as the first argument to `:ranch.start_listener/5`.

If you do not have any established connections, `:ranch.procs(:festooned, :connections)` will return an empty list.