class Message
  HEADER_LENGTH = 20 # header length in bytes
  HEADER_CONFIG = {
    "type" => [0,0], # type field = [start_index, end_index]
    "code" => [1,1],
    "checksum" => [19,19],
    "ttl" => [4,4],
    "seq" => [5,5],
    "fragment_num" => [6,6],
    "fragment_seq" => [7,7],
  }

  def initialize(msg = nil)
    if msg.nil?
      @header = ((0).chr) * HEADER_LENGTH
      @payload = ""
    else
      @msg = msg
      @header = msg[0..(HEADER_LENGTH - 1)]
      @payload = msg[HEADER_LENGTH..(msg.length - 1)]
    end
  end

  def toString()
    @header[HEADER_LENGTH - 1] = checksum()
    return @header + @payload
  end

  def setHeader(header)
    @header = header
  end

  def getHeader()
    return @header
  end

  def setHeaderField(field_name, n)
    field_range = HEADER_CONFIG[field_name]
    # STDOUT.puts n
    @header[field_range[0]..field_range[1]] = n.chr
  end

  def getHeaderField(field_name)
    field_range = HEADER_CONFIG[field_name]
    res = @header[field_range[0]..field_range[1]].ord
    return res
  end

  def setPayLoad(payload)
    @payload = payload
  end

  def getPayLoad()
    return @payload
  end

  def fragment()
    payload_str = @payload
    payload_size = payload_str.bytesize()
    packet_list = []
    if payload_size < $mtu
      packet_list = [self]
    else
      num_of_fragments = (payload_size / $mtu).ceil
      
      payload_list = Util.split_str_by_size(payload_str, $mtu)
      
      fragment_num = payload_list.length
      fragment_seq = 1

      payload_list.each do |payload|
        msg = Message.new
        msg.setHeader(String.new(@header))
        msg.setHeaderField("fragment_num", fragment_num)
        msg.setHeaderField("fragment_seq", fragment_seq)
        msg.setPayLoad(payload)
        packet_list << msg
        fragment_seq += 1
      end
    end

    return packet_list
  end

  def checksum()
    res = @header[0].ord
    for i in (1..HEADER_LENGTH - 2)
      res = res ^ (@header[i].ord)
    end
    return res.chr
  end

  def validate()
    cs = checksum()
    return cs == @header[HEADER_LENGTH - 1]
  end
end
