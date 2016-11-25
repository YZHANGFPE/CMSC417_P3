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

