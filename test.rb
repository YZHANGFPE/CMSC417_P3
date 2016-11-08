require_relative 'message'
require_relative 'utilities'
require 'test/unit'

class TestMessage < Test::Unit::TestCase

  def test_toString
    hdr = "0" * 20
    msg = Message.new(hdr +"Hello")
    assert_equal(hdr + "Hello", msg.toString())
  end

  def test_getHeader
    hdr = "0" * 20
    msg = Message.new(hdr + "Hello")
    assert_equal(hdr, msg.getHeader())
  end

  def test_Type
    msg = Message.new
    msg.setType(0)
    assert_equal(0, msg.getType())
    msg.setType(49)
    assert_equal("1" + "0" * 19, msg.toString())
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

end