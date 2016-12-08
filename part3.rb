require_relative 'global_variables'
require_relative 'control_message_handler'
require_relative 'message'
require_relative 'part2'

module P3
  def P3.circuitb(cmd)
    id = cmd[0]
    dst = cmd[1]
    hops = cmd[2]
    $circuit_info[id] = {"dst" => dst, "hops" => hops}
    hops_array = hops.split(",")
    hops_len = hops_array.length
    next_hop = nil
    if hops_len == 0
      next_hop = dst
    else
      next_hop = hops_array[0]
    end
    $circuit_table[id] = Hash.new()
    hops_array.each do |hop|
      $circuit_table[id][hop] = next_hop
    end
    $circuit_table[id][dst] = next_hop
    msg = Message.new
    msg.setHeaderField("type", 7)
    payload = id + " " + dst + " " + $hostname + " " + hops + " " + $hostname
    msg.setPayLoad(payload)
    CtrlMsg.send($clients[next_hop], msg)
  end

  def P3.circuitm(arr)
    id = arr[0]
    cmd = arr[1]
    args = arr[2..-1]
    case cmd
    when "SENDMSG"; P2.sendmsg(args, true, id)
    when "PING"; P2.ping(args, true, id)
    when "TRACEROUTE"; P2.traceroute(args, true, id)
    when "FTP"; P2.ftp(args, true, id)
    else STDERR.puts "ERROR: INVALID COMMAND FOR CIRCUITM"
    end
  end

  def P3.circuitd(cmd)
    id = cmd[0]
    dst = $circuit_info[id]["dst"]
    hops = $circuit_info[id]["hops"]
    hops_array = hops.split(",")
    hops_len = hops_array.length
    next_hop = nil
    if hops_len == 0
      next_hop = dst
    else
      next_hop = hops_array[0]
    end
    msg = Message.new
    msg.setHeaderField("type", 8)
    payload = id + " " + dst + " " + $hostname + " " + hops + " " + $hostname
    msg.setPayLoad(payload)
    CtrlMsg.send($clients[next_hop], msg)
  end
end
