class Message
  HEADER_LENGTH = 20 # header length in bytes
  TYPE = [0,0] # type field = [start_index, end_index]
  CODE = [1,1]
  CHECK_SUM = [2,3]


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

  def setType(n)
    @header[TYPE[0]..TYPE[1]] = n.chr
  end

  def getType()
    typ = @header[TYPE[0]..TYPE[1]].ord
    return typ
  end

  def setPayLoad(payload)
    @payload = payload
  end

  def getPayLoad()
    return @payload
  end
end
