require_relative 'global_variables'

module Util
  def Util.readNodeFile(filename)
    f = File.open(filename, "r")
    f.each_line do |line|
      line = line.strip()
      arr = line.split(',')
      node = arr[0]
      port = arr[1]
      $port_table[node] = port
    end
    f.close
  end

  def Util.ipToByte(ip)
    ip_seg = ip.split('.')
    res = ""
    for i in 0..3
      res += ip_seg[i].to_i.chr
    end
    return res
  end

  def Util.byteToIp(byte)
    temp = []
    for i in 0..3
      temp[i] = byte[i].ord.to_s
    end
    return temp[0] + "." + temp[1] + "." + temp[2] + "." + temp[3]
  end
    
end
