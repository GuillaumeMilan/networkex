defmodule Networkex.Parser.Tcpdump do
  require Logger
  @moduledoc """
  Networkex.Parser.Tcpdump.stream_tcpdump("data/tmp/test.txt") |> Enum.filter(fn
    %{header: %{protocol_info: [head|_]}} -> head == "UDP,"
    _ -> false
  end) |> Enum.map(fn %{header: %{from: from, to: to}} -> %{from: from, to: to} end) |> Enum.uniq

  Networkex.Parser.Tcpdump.stream_tcpdump("data/tmp/test.txt") |> Enum.filter(fn
    %{header: %{from: _from, to: _to}}-> true
    _ -> false
  end) |> Enum.map(fn %{header: %{from: from, to: to}} -> %{from: from, to: to} end) |> Enum.uniq

  Networkex.Parser.Tcpdump.stream_tcpdump("data/tmp/ranked.txt") |> Stream.map(fn %{message: message} -> Networkex.Parser.Applier.extract_layers_info(message, [Network, Transport]) end) |> Stream.filter(fn x -> x[Transport][:protocol] == :udp end) |> Enum.take 20
  """

  def stream_tcpdump(file_name) do
    stream = File.stream!(file_name)
    stream |> Stream.transform(
      fn -> %{} end,
      fn x, acc ->
        case x do
          "\t"<>line -> {[], Map.update(acc, :message, parse_tcpdump_line(line), fn prev_lines -> prev_lines ++ parse_tcpdump_line(line) end)}
          header -> if acc != %{}, do: {[acc], %{header: parse_tcpdump_header(header)}}, else: {[], %{header: parse_tcpdump_header(header)}}
        end
      end,
        fn acc -> if acc != %{header: :empty} do
          Logger.error("Networkex.Parser.stream_tcpdump from #{file_name} last line not empty last packet ignored") 
          IO.inspect(acc)
        end end)
  end

  def parse_tcpdump_line(line) do
    line |> String.slice(9..47) |> String.split(" ") |> Enum.reject(&(&1 == "")) |> Enum.map(fn 
      <<byte1::binary-2, byte2::binary-2>> -> [byte1, byte2]
      <<byte1::binary-2>> -> [byte1]
    end) |> List.flatten
  end

  def parse_tcpdump_header(header) do
    header = String.slice(header, 0..-2)
    case String.split(header, " ") do
      ["\n"] -> :empty #used for full packet read check
      [""] -> :empty
      [date, "IP", from, ">", to | protocol_info] ->
        %{
          raw: header,
          type: :inet,
          date: date,
          from: from,
          to: String.slice(to, 0..-2),
          protocol_info: protocol_info # -> Add a parser for protocol info
        }
      [date, "IP6", from, ">", to | protocol_info] ->
        %{
          raw: header,
          type: :inet6,
          date: date,
          from: from,
          to: String.slice(to, 0..-2),
          protocol_info: protocol_info # -> Add a parser for protocol info
        }
      header ->
        %{
          type: :unhandled_header,
          raw: header
        }
    end
  end

end
