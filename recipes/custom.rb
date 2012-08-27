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
    log_node.each do |sapp|
      file = File.open("/var/chef/custom.txt", "w")
      file.puts("title:#{sapp}")
      file.puts("file path: #{sapp["file_path"]}")
      file.puts("file size: #{sapp["file_size"]}")
      file.close
    end
end
  
    
  