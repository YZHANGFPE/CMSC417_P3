require_relative 'global_variables'

module Util
  def Util.readNodeFile(filename)
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
end
