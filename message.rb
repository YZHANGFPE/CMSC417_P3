class Message
  HEADER_LENGTH = 20 # header length in bytes
  HEADER_CONFIG = {
    "type" => [0,0], # type field = [start_index, end_index]
    "code" => [1,1],
    "checksum" => [2,3],
    "ttl" => [4,4],
    "seq" => [5,5],
  }


  def initialize(msg = nil)
    if msg.nil?
      @header = "0" * HEADER_LENGTH
      @payload = ""
    else
      @msg = msg
      @header = msg[0..(HEADER_LENGTH - 1)]
      @payload = msg[HEADER_LENGTH..(msg.length - 1)]
    end
  end

  def toString()
    return @header + @payload
  end

  def getHeader()
    return @header
  end

  def setHeaderField(field_name, n)
    field_range = HEADER_CONFIG[field_name]
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
end
