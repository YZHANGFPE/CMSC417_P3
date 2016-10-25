$port = nil
$hostname = nil
$port_table = Hash.new()
$ip_table = Hash.new()
$distance_table = Hash.new("INF")
$next_hop_table = Hash.new("NA")



# --------------------- Part 0 --------------------- # 

def edgeb(cmd)
  srcip = cmd[0]
  dstip = cmd[1]
  dst = cmd[2]
  $ip_table[$hostname] = srcip
  $ip_table[dst] = dstip
  $distance_table[dst] = 1
  $next_hop_table[dst] = dst
  STDOUT.puts "EDGEB: SUCCESS"
end

def dumptable(cmd)
  output_filename = cmd[0]
  output = File.open(output_filename, "w")
  $port_table.each do |dst, port|
    next_hop = $next_hop_table[dst]
    distance = $distance_table[dst]
    output << $hostname << "," << dst << "," << next_hop << "," << distance << "\n"
  end
  output.close
	STDOUT.puts "DUMPTABLE: SUCCESS"
end

def shutdown(cmd)
	STDOUT.puts "SHUTDOWN: not implemented"
	exit(0)
end



# --------------------- Part 1 --------------------- # 
def edged(cmd)
	STDOUT.puts "EDGED: not implemented"
end

def edgew(cmd)
	STDOUT.puts "EDGEW: not implemented"
end

def status()
	STDOUT.puts "STATUS: not implemented"
end


# --------------------- Part 2 --------------------- # 
def sendmsg(cmd)
	STDOUT.puts "SENDMSG: not implemented"
end

def ping(cmd)
	STDOUT.puts "PING: not implemented"
end

def traceroute(cmd)
	STDOUT.puts "TRACEROUTE: not implemented"
end

def ftp(cmd)
	STDOUT.puts "FTP: not implemented"
end

# --------------------- Part 3 --------------------- # 
def circuit(cmd)
	STDOUT.puts "CIRCUIT: not implemented"
end




# do main loop here.... 
def main()

	while(line = STDIN.gets())
		line = line.strip()
		arr = line.split(' ')
		cmd = arr[0]
		args = arr[1..-1]
		case cmd
		when "EDGEB"; edgeb(args)
		when "EDGED"; edged(args)
		when "EDGEW"; edgew(args)
		when "DUMPTABLE"; dumptable(args)
		when "SHUTDOWN"; shutdown(args)
		when "STATUS"; status()
		when "SENDMSG"; sendmsg(args)
		when "PING"; ping(args)
		when "TRACEROUTE"; traceroute(args)
		when "FTP"; ftp(args)
		when "CIRCUIT"; circuit(args)
		else STDERR.puts "ERROR: INVALID COMMAND \"#{cmd}\""
		end
	end

end

def readNodeFile(filename)
  f = File.open(filename, "r")
  f.each_line do |line|
		line = line.strip()
		arr = line.split(',')
		node = arr[0]
		port = arr[1]
    $port_table[node] = port
  end
  f.close
end

def setup(hostname, port, nodes, config)
	$hostname = hostname
	$port = port
  readNodeFile(nodes)
  $distance_table[hostname] = 0
  $next_hop_table[hostname] = hostname

	#set up ports, server, buffers

	main()

end

setup(ARGV[0], ARGV[1], ARGV[2], ARGV[3])





