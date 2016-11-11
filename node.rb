require_relative 'global_variables'
require_relative 'control_message_handler'
require_relative 'utilities'
require_relative 'part0'
require_relative 'part1'
require_relative 'message'

# --------------------- Part 0 --------------------- # 


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

def startServer()
  server = TCPServer.open($port_table[$hostname])
  loop {
    Thread.start(server.accept) do |client|
      CtrlMsg.callback(client)
    end
  }
end

# do main loop here.... 
def main()

	while(line = STDIN.gets())
		line = line.strip()
		arr = line.split(' ')
		cmd = arr[0]
		args = arr[1..-1]
		case cmd
		when "EDGEB"; P0.edgeb(args)
		when "EDGED"; P1.edged(args)
		when "EDGEU"; P1.edgeu(args)
		when "DUMPTABLE"; P0.dumptable(args)
		when "SHUTDOWN"; P0.shutdown(args)
		when "STATUS"; P1.status()
		when "SENDMSG"; sendmsg(args)
		when "PING"; ping(args)
		when "TRACEROUTE"; traceroute(args)
		when "FTP"; ftp(args)
		when "CIRCUIT"; circuit(args)
		else STDERR.puts "ERROR: INVALID COMMAND \"#{cmd}\""
		end
	end

end

def setup(hostname, port, nodes, config)
  $hostname = hostname
  $port = port
  Util.readNodeFile(nodes)
  $distance_table[hostname] = 0
  $next_hop_table[hostname] = hostname
  $network_topology[$hostname] = {"neighbors" => $neighbors}
  Thread.new {
    startServer()
  }

  main()

end

setup(ARGV[0], ARGV[1], ARGV[2], ARGV[3])





