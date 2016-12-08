require 'socket'
require 'thread'

$sequence_num = 0
$port = nil
$hostname = nil
$neighbors = Hash.new()
$port_table = Hash.new()
$ip_table = Hash.new()
$distance_table = Hash.new("INF")
$next_hop_table = Hash.new("NA")
$server = nil
$clients = Hash.new()
$network_topology = Hash.new()
$mtu = 4
$update_interval = nil
$ping_timeout = nil
$receiver_buffer = []
$mutex = Mutex.new
$cv = ConditionVariable.new
$current_time = nil
$flood_triger = 0
$ping_table = Hash.new()
$traceroute_finish = true
$expect_hop_count = "1"
$circuit_table = Hash.new()
$circuit_info = Hash.new()

# SENDMSG Constants and fields
$SENDMSG_HEADER_TYPE = 20

# FTP Constants and fields
$FTP_HEADER_TYPE = 21

# The delimiter for elements of a message. I noticed just using " " caused errors with other
# whitespace.
$DELIM = "~"
$IMPROBABLE_STRING = "!@$!@%$!@$^&$^"

