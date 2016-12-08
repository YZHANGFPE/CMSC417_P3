require_relative 'global_variables'
require_relative 'utilities'

module CtrlMsg

  def CtrlMsg.callback(msg, client)
    case msg.getHeaderField("type")
    when 0; CtrlMsg.edgeb(msg.getPayLoad(), client)
    when 1; CtrlMsg.floodCallBack(msg)
    when 2; CtrlMsg.edgeu(msg.getPayLoad())
    when 3; CtrlMsg.pingCallBack(msg)
    when 4; CtrlMsg.tracerouteCallBack(msg)
    when $SENDMSG_HEADER_TYPE; CtrlMsg.sendmsgCallBack(msg, client)
    when $FTP_HEADER_TYPE; CtrlMsg.ftpCallBack(msg, client)
    else STDERR.puts "ERROR: INVALID MESSAGE \"#{msg}\""
    end
  end

  def CtrlMsg.send(client, msg)
#     STDOUT.puts "In send"
#     STDOUT.puts msg.getPayLoad
    packet_list = msg.fragment()
    packet_list.each do |packet|
      to_send = packet.toString() + "\n"
      num_bytes = to_send.bytesize()
      check = client.write(to_send)
      if check < num_bytes
        return false
      end
    end
    return true
  end

  def CtrlMsg.receive(client)
    while msg_str = client.gets
      if (msg_str.length >= Message::HEADER_LENGTH + 1 and Message.new(msg_str.chop).validate)
        $mutex.synchronize {
          msg = Message.new(msg_str.chop)
#           STDOUT.puts "In receive"
#           STDOUT.puts msg_str.length
#           STDOUT.puts msg.getPayLoad
          fragment_seq = msg.getHeaderField("fragment_seq")
          fragment_num = msg.getHeaderField("fragment_num")
          if fragment_seq == 0
            CtrlMsg.callback(msg, client)
          else
            $receiver_buffer << msg
            if fragment_num == fragment_seq
              res_msg = Util.assemble($receiver_buffer)
              $receiver_buffer.clear()
              CtrlMsg.callback(res_msg, client)
            end
          end
        }   
      end
      sleep(0.01)
    end
  end

  def CtrlMsg.edgeb(msg, client)
    msg = msg.split(',')
    dstip = msg[0]
    srcip = msg[1]
    dst = msg[2]
    $ip_table[$hostname] = srcip
    $ip_table[dst] = dstip
    $distance_table[dst] = 1
    $neighbors[dst] = 1
    $next_hop_table[dst] = dst
    $clients[dst] = client
    CtrlMsg.flood()
    STDOUT.puts "CTRLMSG-EDGEB: SUCCESS"
  end

  def CtrlMsg.edgeu(msg)
    msg = msg.split(' ')
    dst = msg[0]
    cost = msg[1].to_i
    $distance_table[dst] = cost
    $neighbors[dst] = cost
    CtrlMsg.flood()
    STDOUT.puts "CTRLMSG-EDGEU: SUCCESS"
  end

  def CtrlMsg.flood()
    msg = Message.new
    msg.setHeaderField("type", 1)
    msg.setHeaderField("ttl", $port_table.length)
    msg.setHeaderField("seq", Util.nextSeqNum())
    msg_str = $hostname + "\t"
    if $neighbors.length > 0
      $neighbors.each do |dst, distance|
        msg_str += dst + "," + distance.to_s + "\t"
      end
      msg.setPayLoad(msg_str)
      $clients.each do |dst, client|  
        CtrlMsg.send(client, msg)
      end
#       STDOUT.puts "CTRLMSG-FLOOD: SUCCESS"
    end
  end

  def CtrlMsg.floodCallBack(msg)
#     STDOUT.puts "In flood call back"
#     STDOUT.puts msg.getPayLoad()
    ttl = msg.getHeaderField("ttl")
    sn = msg.getHeaderField("seq")
    if ttl == 0
      return
    else
      msg_payload = msg.getPayLoad()
      payload_array = msg_payload.split("\t")
      host = payload_array[0]
      if (host != $hostname and ($network_topology[host] == nil or $network_topology[host]["sn"] != sn))
        host_dist_tbl = Hash.new()
        for i in 1..(payload_array.length - 1)
          neighbor_dist_pair = payload_array[i].split(",")
          host_dist_tbl[neighbor_dist_pair[0]] = neighbor_dist_pair[1].to_i
        end
        $network_topology[host] = {"sn" => sn, "neighbors" => host_dist_tbl}
        msg.setHeaderField("ttl", ttl - 1)
        $clients.each do |dst, client|
          CtrlMsg.send(client, msg)
        end
        if Util.checkTopology
          Util.updateRoutingTable()
        end
#         STDOUT.puts "CTRLMSG-FLOODCALLBACK: SUCCESS"
      end
    end
    
  end

  def CtrlMsg.pingCallBack(msg)
    code = msg.getHeaderField("code")
    payload = msg.getPayLoad.split(' ')
    src = payload[0]
    dst = payload[1]
    seq_id = payload[2]
    if code == 0
      # forwrd
      if dst == $hostname
        msg.setHeaderField("code", 1)
        client = $clients[$next_hop_table[src]]
        CtrlMsg.send(client, msg)
      else
        client = $clients[$next_hop_table[dst]]
        CtrlMsg.send(client, msg)
      end
    else
      # backward
      if src == $hostname
        if $ping_table.has_key?(seq_id)
          rtp = $current_time - $ping_table[seq_id]
          STDOUT.puts (seq_id + " " + dst + " " + rtp.to_s)
          $ping_table.delete(seq_id)
        end
      else
        client = $clients[$next_hop_table[src]]
        CtrlMsg.send(client, msg)
      end
    end
  end

  def CtrlMsg.tracerouteCallBack(msg)
    code = msg.getHeaderField("code")
    payload = msg.getPayLoad.split(' ')
    src = payload[0]
    dst = payload[1]
    host_id = payload[2]
    hop_count = payload[3]
    time = payload[4]
    if code == 0
      # forwrd
      hop_count = (hop_count.to_i + 1).to_s
      ret_payload = Array.new(payload)
      ret_payload[2] = $hostname
      ret_payload[3] = hop_count
      ret_payload[4] = ($current_time.to_f.round(4) - time.to_f).round(4).abs.to_s
      ret_msg = Message.new
      ret_msg.setHeaderField("type", 4)
      ret_msg.setHeaderField("code", 1)
      ret_msg.setPayLoad(ret_payload.join(" "))
      CtrlMsg.send($clients[$next_hop_table[src]], ret_msg)
      if dst != $hostname
        payload[3] = hop_count
        msg.setPayLoad(payload.join(" "))
        CtrlMsg.send($clients[$next_hop_table[dst]], msg)
      end
    else
      # backward
      if src == $hostname
        STDOUT.puts(hop_count + " " + host_id + " " + time)
        $expect_hop_count = (hop_count.to_i + 1).to_s
        if host_id == dst 
          $traceroute_finish = true
        end
      else
        client = $clients[$next_hop_table[src]]
        CtrlMsg.send(client, msg)
      end
    end
  end

  def CtrlMsg.sendmsgCallBack(msg, client)
    code = msg.getHeaderField("code")
    payload = msg.getPayLoad().split(" ")
    src = payload.shift()
    dst = payload.shift()
    if dst == $hostname
      payload = payload.join(" ")
      to_print = "SENDMSG: %s -- > %s"
      STDOUT.puts(to_print % [src, payload])
    else
      forward_client = $clients[$next_hop_table[dst]]
      CtrlMsg.send(forward_client, msg)
    end
  end
  
  def CtrlMsg.ftpCallBack(msg, client)
    payload = msg.getPayLoad().split($DELIM)
    src = payload.shift()
    dst = payload.shift()
    if dst == $hostname  
      file_size_ideal = payload.shift().to_i()
      fname = payload.shift()
      fpath = payload.shift()
      file_content = payload.join($DELIM).gsub($IMPROBABLE_STRING, "\n")
      
      success_output = "FTP: #{src} -- > #{fpath}/#{fname}"
      error_output = "FTP ERROR: #{src} -- > #{fpath}/#{fname}"

      file_size_actual = file_content.bytesize()
      #if file_size_actual < file_size_ideal
      #  STDOUT.puts(error_output)
      #else
      File.write(fpath + "/" + fname, file_content)
      STDOUT.puts(success_output)
      #end
    else
      forward_client = $clients[$next_hop_table[dst]]
      CtrlMsg.send(forward_client, msg)
    end
  end

end
