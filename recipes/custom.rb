#default
case node.os
when "linux"
  "something"
when "aix"
  "do something"
when "hpux"
  "do default something"
end

#custom
#logs = data_bag("logs")
nodes = data_bag_item("logs","nodes")

nodes.each do |log_node|
    log_node.each do |sapp,keys|
      file = File.open("/var/chef/custom.txt", "w")
      file.puts("title:#{sapp}")
      file.puts("body: #{keys["matches"]}")
      file.close
    end
end
  
    
  