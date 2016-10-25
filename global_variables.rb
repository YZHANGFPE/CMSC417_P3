require 'socket'

$port = nil
$hostname = nil
$port_table = Hash.new()
$ip_table = Hash.new()
$distance_table = Hash.new("INF")
$next_hop_table = Hash.new("NA")
$server = nil
$clients = Hash.new()

