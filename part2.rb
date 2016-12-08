require_relative 'global_variables'
require_relative 'control_message_handler'
require_relative 'message'
require_relative 'debug'

module P2
  def P2.ping(cmd, circuit = false, circuit_id = nil)
    dst = cmd[0]
    next_hop = $next_hop_table[dst]
    if circuit
      if $circuit_table.has_key?(circuit_id) and $circuit_table[circuit_id].has_key?(dst)
        next_hop = $circuit_table[circuit_id][dst]
      else
        next_hop = "NA"
      end
    end
    if next_hop == "NA" || next_hop == $hostname
      if circuit
        STDOUT.puts ("CIRCUIT #{circuit_id} /" + "PING ERROR: HOST UNREACHABLE")
      else
        STDOUT.puts "PING ERROR: HOST UNREACHABLE"
      end
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
      if circuit
        msg.setHeaderField("circuit", 1)
        msg.setPayLoad($hostname + " " + dst + " " + seq_id.to_s + " " + circuit_id)
      end
      $ping_table[seq_id.to_s] = $current_time
      CtrlMsg.send(client, msg)
      Thread.new {
        seq_id_ = seq_id
        sleep($ping_timeout)
        if $ping_table.has_key?(seq_id_.to_s)
          if circuit
            STDOUT.puts ("CIRCUIT #{circuit_id} /" + "PING ERROR: HOST UNREACHABLE")
          else
            STDOUT.puts "PING ERROR: HOST UNREACHABLE"
          end
        end
        $ping_table.delete(seq_id_.to_s)
      }
      sleep(delay)
    end
  end

  def P2.traceroute(cmd, circuit = false, circuit_id = nil)
    dst = cmd[0]
    next_hop = $next_hop_table[dst]
    if circuit
      if $circuit_table.has_key?(circuit_id) and $circuit_table[circuit_id].has_key?(dst)
        next_hop = $circuit_table[circuit_id][dst]
      else
        next_hop = "NA"
      end
    end
    if next_hop == "NA"
      if circuit
        STDOUT.puts ("CIRCUIT " + circuit_id + " /" + "TRACEROUTE ERROR: HOST UNREACHABLE")
      else
        STDOUT.puts "TRACEROUTE ERROR: HOST UNREACHABLE"
      end
      return
    end
    if circuit
      STDOUT.puts("CIRCUIT #{circuit_id} /" + "0 " + $hostname + " 0.00")
    else
      STDOUT.puts("0 " + $hostname + " 0.00")
    end
    if next_hop == $hostname
      return
    end
    client = $clients[next_hop]
    msg = Message.new
    msg.setHeaderField("type", 4)
    msg.setHeaderField("code", 0)
    msg.setPayLoad($hostname + " " + dst + " " + dst + " 0 " + $current_time.to_f.round(4).to_s)
    if circuit
      msg.setHeaderField("circuit", 1)
      msg.setPayLoad($hostname + " " + dst + " " + dst + " 0 " + $current_time.to_f.round(4).to_s + " " + circuit_id)
    end
    $traceroute_finish = false
    $expect_hop_count = "1"
    CtrlMsg.send(client, msg)
    start_time = $current_time
    while $current_time - start_time < $ping_timeout
      if $traceroute_finish
        if circuit
          STDOUT.puts ("CIRCUIT " + circuit_id + " /" + "TRACEROUTE: SUCCESS")
        else
          STDOUT.puts "TRACEROUTE: SUCCESS"
        end
        return
      end
      sleep(0.1)
    end
    if circuit
      STDOUT.puts("CIRCUIT " + circuit_id + " /" +"TIMEOUT ON HOPCOUNT " + $expect_hop_count)
    else
      STDOUT.puts("TIMEOUT ON HOPCOUNT " + $expect_hop_count)
    end
  end

  def P2.sendmsg(cmd, circuit = false, circuit_id = nil)
    Debug.assert { cmd.length() >= 2 }
    Debug.assert { cmd.kind_of?(Array) }
    
    dst = cmd[0]
    msg = $hostname + " " + dst + " " + cmd[1..-1].join(" ")
  
    error_msg = "SENDMSG ERROR: HOST UNREACHABLE"

    # Make sure dst is reachable
    if ($next_hop_table.include?(dst) && $next_hop_table[dst] != "NA" &&
        $clients.has_key?($next_hop_table[dst]))
      next_hop = $next_hop_table[dst]
      client = $clients[next_hop]
    else
      STDOUT.puts(error_msg)
      return
    end
    
    # Construct the packet
    packet = Message.new()
    packet.setHeaderField("type", $SENDMSG_HEADER_TYPE)
    packet.setHeaderField("code", 0)
    packet.setPayLoad(msg)

    success = CtrlMsg.send(client, packet)
    if !success
      STDOUT.puts(error_msg)
    end
  end
  
  def P2.ftp(cmd, circuit = false, circuit_id = nil)
    Debug.assert { cmd.length() >= 3 }
    Debug.assert { cmd.kind_of?(Array) }
    
    dst,fname,fpath = cmd[0], cmd[1], cmd[2]

    success_output = "FTP #{fname} -- > #{dst} in %s at %s"
    error_output = "FTP ERROR: #{fname} -- > #{dst} INTERRUPTED AFTER %s"
    
    # Make sure dst is reachable
    if ($next_hop_table.include?(dst) && $next_hop_table[dst] != "NA" &&
        $clients.has_key?($next_hop_table[dst]))
      next_hop = $next_hop_table[dst]
      client = $clients[next_hop]
    else
      STDOUT.puts(error_output % ["0"])
      return
    end

    # Construct the packet, keeping tabs on its length
    file_obj = File.open(fname, "r")
    file_contents = file_obj.read().gsub("\n",$IMPROBABLE_STRING)
    file_obj.close()

    file_size = file_contents.bytesize()
    msg = [$hostname, dst, file_size.to_s(), fname, fpath, file_contents].join($DELIM)
    msg_offset = msg.bytesize() - file_size

    packet = Message.new()
    packet.setHeaderField("type", $FTP_HEADER_TYPE)
    packet.setHeaderField("code", 0)
    packet.setPayLoad(msg)
    header_offset = packet.toString().bytesize() - msg_offset - file_size + "\n".bytesize()

    packet_offset = msg_offset
    total_bytes_sent = 0

    # Send the (fragmented) packet, keeping tabs on how many bytes reach the
    # destination
    packet_list = packet.fragment()
    t_start = $current_time
    
    packet_list.each do |packet|
      to_send = packet.toString() + "\n"
      packet_offset += header_offset
      num_bytes = to_send.bytesize()
      check = client.write(to_send)
      total_bytes_sent += check
      
      if check < num_bytes
        bytes_from_file_sent = total_bytes_sent - packet_offset
        STDOUT.puts(error_output % [bytes_from_file_sent])
        return
      end
    end
    
    t_end = $current_time
    t_total = t_end - t_start

    bytes_from_file_sent = total_bytes_sent - packet_offset
    speed = bytes_from_file_sent / t_total

    STDOUT.puts(success_output % [t_total, speed])

  end

end
