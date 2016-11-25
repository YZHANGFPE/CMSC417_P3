require_relative 'global_variables'
require_relative 'control_message_handler'
require_relative 'message'

module P0

  def P0.edgeb(cmd)
    srcip = cmd[0]
    dstip = cmd[1]
    dst = cmd[2]
    $ip_table[$hostname] = srcip
    $ip_table[dst] = dstip
    $distance_table[dst] = 1
    $neighbors[dst] = 1
    $next_hop_table[dst] = dst
    port = $port_table[dst]
    s = TCPSocket.open(dstip, port)
    $clients[dst] = s
    msg = Message.new
    msg.setHeaderField("type", 0)
    msg.setPayLoad(srcip + "," + dstip + "," + $hostname)
    CtrlMsg.send(s, msg)
    CtrlMsg.flood()
    Thread.new {
      CtrlMsg.receive(s)
    }
    STDOUT.puts "EDGEB: SUCCESS"
  end

  def P0.dumptable(cmd)
    output_filename = cmd[0]
    output = File.open(output_filename, "w")
    $port_table.each do |dst, port|
      next_hop = $next_hop_table[dst]
      distance = $distance_table[dst]
      output << $hostname << "," << dst << "," << next_hop << "," << distance << "\n"
    end
    output << $network_topology
    output << $distance_table
    output << $next_hop_table
    output.close
    STDOUT.puts "DUMPTABLE: SUCCESS"
  end

  def P0.shutdown(cmd)
    if $server != nil
      $server.close
    end
    $clients.each do |hostname, client|
      STDOUT.puts "Close connection to #{hostname}"
      client.close
    end
    STDOUT.puts "SHUTDOWN: SUCCESS"
    STDOUT.flush
    STDERR.flush
    exit(0)
  end

end
