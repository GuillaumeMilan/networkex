defmodule Networkex.Parser.Network do
  def parse_message(message) do
    [version_byte|_] = message
    <<version::4, _::4>> = Base.decode16!(String.upcase(version_byte))
    parse_message(version, message)
  end
  def parse_message(4,message) do
    [
      l11,l12,l13,l14,
      l21,l22,l23,l24,
      l31,l32,l33,l34,
      l41,l42,l43,l44,
      l51,l52,l53,l54 | message
    ] = message
    <<4::4, ihl::4, service::8, length::16>> = Base.decode16!(String.upcase(Enum.join([l11,l12,l13,l14], "")))
    <<identification::16, flags::3, fragment_offset::13>> = Base.decode16!(String.upcase(Enum.join([l21, l22, l23, l24], "")))
    <<time_to_live::8, protocol::8, _check_sum::16>> = Base.decode16!(String.upcase(Enum.join([l31, l32, l33, l34], "")))
    <<src_address::32>> = Base.decode16!(String.upcase(Enum.join([l41, l42, l43, l44], "")))
    <<dst_address::32>> = Base.decode16!(String.upcase(Enum.join([l51, l52, l53, l54], "")))
    optional_lines = ihl - 5
    {options, message} = remove_options(optional_lines, message)
    %{
      version: 4,
      ihl: ihl,
      service: service,
      length: length,
      identification: identification,
      flags: flags,
      fragment_offset: fragment_offset,
      src_address: <<src_address::32>>,
      dst_address: <<dst_address::32>>,
      protocol: protocol,
      options: options,
      message: message,

    }
  end
  def parse_message(6,message) do
    %{
      version: 6,
      message: [],
      status: :not_yet_implemented
    }
  end

  def remove_options(0, message) do
    {[], message}
  end
  def remove_options(optional_lines, message) do
    [o1,o2,o3,o4|message] = message
    {other_options, message} = remove_options(optional_lines - 1, message)
    {[o1,o2,o3,o4] ++ other_options, message}
  end
end
