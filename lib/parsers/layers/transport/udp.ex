defmodule Parser.Udp do
  def parse_message(message) do
    [
      src_port1, src_port2,
      dst_port1, dst_port2,
      lt1,lt2,
      cs1,cs2 | message
    ] = message
    <<src_port::16>> = Base.decode16!(String.upcase(Enum.join([src_port1, src_port2], "")))
    <<dst_port::16>> = Base.decode16!(String.upcase(Enum.join([dst_port1, dst_port2], "")))
    <<lt::16>> = Base.decode16!(String.upcase(Enum.join([lt1, lt2], "")))
    <<checksum::16>> = Base.decode16!(String.upcase(Enum.join([cs1,cs2], "")))
    %{
      protocol: :udp,
      dst_port: dst_port,
      src_port: src_port,
      checksum: checksum,
      length: lt,
      message: message,
    }
  end
end
