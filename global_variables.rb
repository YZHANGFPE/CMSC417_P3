require 'socket'

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

