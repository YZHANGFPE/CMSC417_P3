require_relative 'global_variables'

module CtrlMsg

  def CtrlMsg.edgebTCP(msg, client)
    msg = msg.split(' ')
    dstip = msg[0]
    srcip = msg[1]
    dst = msg[2]
    $ip_table[$hostname] = srcip
    $ip_table[dst] = dstip
    $distance_table[dst] = 1
    $next_hop_table[dst] = dst
    $clients[dst] = client
    STDOUT.puts "EDGEBTCP: SUCCESS"
  end

end
