# NetworkAnalyser

Network packet analyser written in elixir.
The objective of the projet is to be able to read an output file from the tcpdump command

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `network_analyser` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:networkex, git: "https://github.com/GuillaumeMilan/networkex.git", branch: "master"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/network_analyser](https://hexdocs.pm/network_analyser).

# Usage example

Assuming `example.txt` is containing an output result of the `tcpdump` command,
you can use the parsers as follow:

```elixir
streamed_packets = Parser.Tcpdump.stream_tcpdump("example.txt")
translated_packets = Stream.map(streamed_packets, fn %{message: message} -> Parser.Applier.extract_layers_info(message, [Network, Transport]) end)
translated_packets |> Enum.take 1
```
