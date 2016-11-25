require_relative 'message'
require_relative 'utilities'
require 'test/unit'

class TestMessage < Test::Unit::TestCase

  @@zero = (0).chr

  def test_toString
    hdr = @@zero * Message::HEADER_LENGTH
    msg = Message.new(hdr +"Hello")
    assert_equal(hdr + "Hello", msg.toString())
  end

  def test_getHeader
    hdr = @@zero * Message::HEADER_LENGTH
    msg = Message.new(hdr + "Hello")
    assert_equal(hdr, msg.getHeader())
  end

  def test_setHeaderField
    msg = Message.new
    msg.setHeaderField("type", 1)
    assert_equal(1, msg.getHeaderField("type"))
  end

  def test_empty_msg
    msg = Message.new
    hdr = msg.getHeader()
    assert_equal(hdr,  msg.toString())
    payLoad = "Hello"
    msg.setPayLoad(payLoad)
    assert_equal(payLoad, msg.getPayLoad())
  end

  def test_ip_conversion
    ip = "48.49.97.255"
    byte = Util.ipToByte(ip)
    assert_equal(ip, Util.byteToIp(byte))
  end

  def test_fragment_1
    msg = Message.new
    assert_equal(0, msg.getHeaderField("type"))
    payLoad = "Hello"
    msg.setPayLoad(payLoad)
    packet_list = msg.fragment()
    res_msg = Util.assemble(packet_list)
    assert_equal(payLoad, res_msg.getPayLoad())
  end

  def test_fragment_2
    msg = Message.new
    assert_equal(0, msg.getHeaderField("type"))
    payLoad = ""
    msg.setPayLoad(payLoad)
    packet_list = msg.fragment()
    res_msg = Util.assemble(packet_list)
    assert_equal(payLoad, res_msg.getPayLoad())
  end

  def test_checksum
    msg = Message.new
    msg.setHeaderField("type", 1)
    payLoad = ""
    msg.setPayLoad(payLoad)
    msg_str = msg.toString()
    return_msg = Message.new(msg_str)
    assert_equal(true, return_msg.validate)
    return_msg.setHeaderField("type", 2)
    assert_equal(false, return_msg.validate)
  end

  def test_checkTopology
    $network_topology = {"n4"=>{"neighbors"=>{"n3"=>1}}, "n3"=>{"sn"=>5, "neighbors"=>{"n2"=>1, "n4"=>1}}, "n1"=>{"sn"=>5, "neighbors"=>{"n2"=>1}}}
    assert_equal(false, Util.checkTopology)
    $network_topology = {"n4"=>{"neighbors"=>{"n3"=>1}}, "n3"=>{"sn"=>5, "neighbors"=>{"n2"=>1, "n4"=>1}}, "n1"=>{"sn"=>5, "neighbors"=>{"n2"=>1}}, "n2"=>{"sn"=>5, "neighbors"=>{"n1"=>1}}}
    assert_equal(true, Util.checkTopology)
  end

end
