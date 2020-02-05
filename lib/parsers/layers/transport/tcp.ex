defmodule Networkex.Parser.Tcp do
  def parse_message(message) do
    [
      src_port1, src_port2, dst_port1, dst_port2,
      seq_number1, seq_number2, seq_number3, seq_number4,
      ack_number1, ack_number2, ack_number3, ack_number4,
      l41, l42, w1, w2,
      cs1,cs2,up1,up2 | message
    ] = message
    <<src_port::16>> = Base.decode16!(String.upcase(Enum.join([src_port1, src_port2], "")))
    <<dst_port::16>> = Base.decode16!(String.upcase(Enum.join([dst_port1, dst_port2], "")))
    <<seq_number::32>> = Base.decode16!(String.upcase(Enum.join([seq_number1, seq_number2, seq_number3, seq_number4], "")))
    <<ack_number::32>> = Base.decode16!(String.upcase(Enum.join([ack_number1, ack_number2, ack_number3, ack_number4], "")))
    <<offset::4, reserved::6, urg::1, ack::1, psh::1, rst::1, syn::1, fin::1>> = Base.decode16!(String.upcase(Enum.join([l41, l42], "")))
    <<window::16>> = Base.decode16!(String.upcase(Enum.join([w1, w2], "")))
    <<checksum::16>> = Base.decode16!(String.upcase(Enum.join([cs1,cs2], "")))
    <<urgent_pointer::16>> = Base.decode16!(String.upcase(Enum.join([up1,up2], "")))
    {options, message} = parse_options(offset-5, message)
    %{
      protocol: :tcp,
      dst_port: dst_port,
      src_port: src_port,
      seq_number: seq_number,
      ack_number: ack_number,
      offset: offset,
      reserved: reserved,
      urg: urg,
      ack: ack,
      psh: psh,
      rst: rst,
      syn: syn,
      fin: fin,
      window: window,
      checksum: checksum,
      urgent_pointer: urgent_pointer,
      options: options,
      message: message,
    }
  end
  def parse_options(0, message) do
    {[], message}
  end
  def parse_options(offset, message) do
    [op1,op2,op3,op4 | message] = message
    {options, message} = parse_options(offset-1, message)
    {[op1,op2,op3,op4] ++ options, message}
  end
end
