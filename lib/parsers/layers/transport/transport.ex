defmodule Networkex.Parser.Transport do
  def get_module_from_protocol(protocol) do
    case protocol do
      6 -> Tcp
      17 -> Udp
      _ -> :undefined
    end
  end
end
