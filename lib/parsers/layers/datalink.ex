defmodule Parser.Datalink do
  def parse_message(message) do
    [
      cda1,cda2,cda3,cda4,cda5,cda6,
      csa1,csa2,csa3,csa4,csa5,csa6,
      lt1,lt2 | message
    ] = message
    <<cda::48>>  = Base.decode16!(String.upcase(Enum.join([cda1,cda2,cda3,cda4,cda5,cda6], "")))
    <<csa::48>>  = Base.decode16!(String.upcase(Enum.join([csa1,csa2,csa3,csa4,csa5,csa6], "")))
    <<lt::16>>   = Base.decode16!(String.upcase(Enum.join([lt1,lt2], "")))
    parse_header(lt, %{mac_dest: <<cda::48>>, mac_src: <<csa::48>>}, message)
  end

  def parse_header(0x8100, acc, message) do
    [
      l11,l12,
      lt1,lt2 | message
    ] = message
    <<cpc::3,c::1,cvid::12>> = Base.decode16!(String.upcase(Enum.join([l11,l12], "")))
    <<lt::16>> = Base.decode16!(String.upcase(Enum.join([lt1,lt2], "")))
    parse_header(lt, Map.merge(
      acc,
      %{
        cpc: cpc,
        c: c,
        cvid: cvid
      }
    ), message)
  end
  def parse_header(0x88a8, acc, message) do
    [
      l11,l12,
      lt1,lt2 | message
    ] = message
    <<spc::3, d::1, svid::12>> = Base.decode16!(String.upcase(Enum.join([l11,l12], "")))
    <<lt::16>> = Base.decode16!(String.upcase(Enum.join([lt1,lt2], "")))
    parse_header(lt, Map.merge(
      acc,
      %{
        spc: spc,
        d: d,
        svid: svid
      }
    ), message)
  end
  def parse_header(0x88e7, acc, message) do
    [
      l11,
      l21,l22,l23,
      cda1,cda2,cda3,cda4,cda5,cda6,
      csa1,csa2,csa3,csa4,csa5,csa6,
      lt1,lt2 | message
    ] = message
    <<ipcp::3, d::1, u::1, res::3>> = Base.decode16!(String.upcase(Enum.join([l11], "")))
    <<isid::24>> = Base.decode16!(String.upcase(Enum.join([l21,l22,l23], "")))
    <<cda::48>> = Base.decode16!(String.upcase(Enum.join([cda1,cda2,cda3,cda4,cda5,cda6], "")))
    <<csa::48>> = Base.decode16!(String.upcase(Enum.join([csa1,csa2,csa3,csa4,csa5,csa6], "")))
    <<lt::16>> = Base.decode16!(String.upcase(Enum.join([lt1,lt2], "")))
    bda = acc.mac_dest
    bsa = acc.mac_src
    parse_header(lt, Map.merge(
        acc,
        %{
          bda: bda,
          bsa: bsa,
          mac_src: csa,
          mac_dest: cda,
          ipcp: ipcp,
          d: d,
          u: u,
          res: res,
          isid: isid
        }
      ),
      message)
  end
  def parse_header(0x893f, acc, message) do
    [
      l11,l12,
      l21,l22,l23,l24,
      lt1,lt2 | message
    ] = message
    <<epcp::3, d::1, ingress_ecid_base::12>> = Base.decode16!(String.upcase(Enum.join([l11,l12], "")))
    <<res::2, grp::2, ecid_base::12, ingress_ecid_ext::8, ecid_ext::8>> = Base.decode16!(String.upcase(Enum.join([l21,l22,l23,l24], "")))
    <<lt::16>> = Base.decode16!(String.upcase(Enum.join([lt1,lt2], "")))
    parse_header(lt, Map.merge(
        acc,
        %{
          epcp: epcp,
          d: d,
          ingress_ecid_base: ingress_ecid_base,
          res: res,
          grp: grp,
          ecid_base: ecid_base,
          ingress_ecid_ext: ingress_ecid_ext,
          ecid_ext: ecid_ext,
        }
      ),
      message)
  end
  def parse_header(lt, acc, message) do
    Map.merge(
      acc,
      %{
        length: lt,
        message: message,#parse_ip_package(message)
      }
    )
  end
end
