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
    STDOUT.puts "PING: SUCCESS"
  end
end
