defmodule Networkex.Parser.Applier do

  @type layer :: Datalink | Network | Transport
  @type info :: %{
    message: list(), #list(Base16 encoded byte)
  }

  def parsable_layers do
    [Datalink, Network, Transport]
  end
  def accumulate_info(layer, acc, info, layers) do
    if layer in layers do
      Map.put(acc, layer, Map.delete(info, :message))
    else
      acc
    end
  end

  def extract_layers_info(message, layers \\ [Datalink, Network, Transport]) do
    last_layer = List.last(layers)
    acc = %{}
    Enum.reduce_while(parsable_layers(), {%{}, %{message: message}}, fn layer, {acc, info} ->
      info = extract_layer_info(layer, info.message, info)
      acc = accumulate_info(layer, acc, info, layers)
      if last_layer == layer do
        {:halt, Map.put(acc, :message, info.message)}
      else
        {:cont, {acc, info}}
      end
    end)
  end
  def extract_layer_info(Datalink, message, _) do
    info = Networkex.Parser.Datalink.parse_message(message)
  end
  def extract_layer_info(Network, message, _) do
    info = Networkex.Parser.Network.parse_message(message)
  end
  def extract_layer_info(Transport, message, %{protocol: protocol}) do
    module = Networkex.Parser.Transport.get_module_from_protocol(protocol)
    if module != :undefined do
      info = apply(Module.concat([Networkex.Parser, module]), :parse_message, [message])
    else
      %{message: message}
    end
  end
end
