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
      $distance_table[node] = "INF"
      $next_hop_table[node] = "NA"
    end
    f.close
  end

  def Util.parse_config_file(fname)
    f = File.open(fname, "r")
    update_interval = mtu = ping_timeout = nil
    f.each_line do |line|
      line = line.strip().split("=")
      option = line[0].upcase
      value = Integer(line[1])
      if option == "UPDATEINTERVAL"
        update_interval = value
      elsif option == "MAXPAYLOAD"
        mtu = value
      elsif option == "PINGTIMEOUT"
        ping_timeout = value
      end
    end
    f.close()

    return update_interval, mtu, ping_timeout
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

  def Util.nextSeqNum()
    $sequence_num = ($sequence_num + 1) % 256
    return $sequence_num
  end

  def Util.isSmaller(a, b)
    if b == "INF"
      return true
    elsif a == "INF"
      return false
    else
      return a < b
    end
  end
        
  def Util.findMinDistNode(sptSet)
    min_dist = "INF"
    min_node = nil
    $distance_table.each do |node, dist|
      if isSmaller(dist, min_dist) and !(sptSet.include? node)
        min_dist = dist
        min_node = node
      end
    end
    return min_node
  end

  def Util.updateRoutingTable()
  # Dijkstra’s shortest path algorithm    
    $distance_table.each do |node, dist|
      if node != $hostname
        $distance_table[node] = "INF"
      end
    end
    sptSet = []
    while sptSet.length < $network_topology.length
      current_node = findMinDistNode(sptSet)
      sptSet << current_node
      dist_to_current_node = $distance_table[current_node]
      neighbor_dist_tbl = $network_topology[current_node]["neighbors"]
      neighbor_dist_tbl.each do |neighbor, dist|
        proposed_dist = dist_to_current_node + dist
        if isSmaller(proposed_dist, $distance_table[neighbor])
          $distance_table[neighbor] = proposed_dist
          if current_node != $hostname
            $next_hop_table[neighbor] = $next_hop_table[current_node]
          end
        end
      end
    end
  end

  def Util.split_str_by_size(str, size)
    return str.chars.each_slice(size).map(&:join)
  end

  def Util.assemble(packet_list)
    # assert_operator packet_list.length, :>, 0
    payload_full_str = ""
    hdr = String.new(packet_list[0].getHeader())
    msg = Message.new
    msg.setHeader(hdr)
    msg.setHeaderField("fragment_num", 0)
    msg.setHeaderField("fragment_seq", 0)
    packet_list.each do |packet|
      payload_full_str += packet.getPayLoad()
    end
    msg.setPayLoad(payload_full_str)
    return msg
  end

end
