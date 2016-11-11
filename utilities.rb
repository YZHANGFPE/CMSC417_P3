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

end
