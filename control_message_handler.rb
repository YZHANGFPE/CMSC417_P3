require_relative 'global_variables'

module CtrlMsg

  def CtrlMsg.edgebTCP(cmd, client)
    dstip = cmd[0]
    srcip = cmd[1]
    dst = cmd[2]
    $ip_table[$hostname] = srcip
    $ip_table[dst] = dstip
    $distance_table[dst] = 1
    $next_hop_table[dst] = dst
    $clients[dst] = client
    STDOUT.puts "EDGEBTCP: SUCCESS"
  end

end
