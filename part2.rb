require_relative 'global_variables'
require_relative 'control_message_handler'
require_relative 'message'

module P2
  def P2.ping(cmd)
    dst = cmd[0]
    next_hop = $next_hop_table[dst]
    if next_hop == "NA" || next_hop == $hostname
      STDOUT.puts "PING ERROR: HOST UNREACHABLE"
      return
    end
    n = cmd[1].to_i
    delay = cmd[2].to_i
    client = $clients[next_hop]
    for seq_id in (0..(n - 1))
      msg = Message.new
      msg.setHeaderField("type", 3)
      msg.setHeaderField("code", 0)
      msg.setPayLoad($hostname + " " + dst + " " + seq_id.to_s)
      $ping_table[seq_id.to_s] = $current_time
      CtrlMsg.send(client, msg)
      Thread.new {
        seq_id_ = seq_id
        sleep($ping_timeout)
        if $ping_table.has_key?(seq_id_.to_s)
          STDOUT.puts "PING ERROR: HOST UNREACHABLE"
        end
        $ping_table.delete(seq_id_.to_s)
      }
      sleep(delay)
    end
  end

  def P2.traceroute(cmd)
    dst = cmd[0]
    next_hop = $next_hop_table[dst]
    if next_hop == "NA"
      STDOUT.puts "TRACEROUTE ERROR: HOST UNREACHABLE"
      return
    end
    STDOUT.puts("0 " + $hostname + " 0.00")
    if next_hop == $hostname
      return
    end
    client = $clients[next_hop]
    msg = Message.new
    msg.setHeaderField("type", 4)
    msg.setHeaderField("code", 0)
    msg.setPayLoad($hostname + " " + dst + " " + dst + " 0 " + $current_time.to_f.round(4).to_s)
    $traceroute_finish = false
    $expect_hop_count = "1"
    CtrlMsg.send(client, msg)
    start_time = $current_time
    while $current_time - start_time < $ping_timeout
      if $traceroute_finish
        STDOUT.puts "TRACEROUTE: SUCCESS"
        return
      end
      sleep(0.1)
    end
    STDOUT.puts("TIMEOUT ON HOPCOUNT " + $expect_hop_count)
  end
end
