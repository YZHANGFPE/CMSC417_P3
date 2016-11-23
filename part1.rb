# part1 routing core
require_relative 'global_variables'
require_relative 'control_message_handler'
require_relative 'message'

module P1

  def P1.edgeu(cmd)
    dst = cmd[0]
    cost = cmd[1].to_i
    $distance_table[dst] = cost
    $neighbors[dst] = cost
    client = $clients[dst]
    msg = Message.new
    msg.setHeaderField("type", 2)
    msg.setPayLoad($hostname + " " + cost.to_s)
    CtrlMsg.send(client, msg)
    CtrlMsg.flood()
    STDOUT.puts "EDGEU: SUCCESS"
  end

  def P1.edged(cmd)
    dst = cmd[0]
    $ip_table.delete(dst)
    $distance_table[dst] = "INF"
    $neighbors.delete(dst)
    $next_hop_table[dst] = "NA"
    client = $clients[dst]
    client.close()
    $clients.delete(dst)
    CtrlMsg.flood()
    STDOUT.puts "EDGED: SUCCESS"
  end

  def P1.status()
    neighbors = []
    $neighbors.each do |node, distance|
      neighbors << node
    end
    neighbors.sort
    msg = "Name: " + $hostname + "\n"
    msg += "Port: " + $port + "\n"
    msg += "Neighbors: " 
    neighbors.each do |node|
      msg += node + ","
    end
    if msg[-1] == ","
      msg = msg.chop
    end
    STDOUT.puts msg
  end

end
