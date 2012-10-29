# Reconstructed Clean Filesystem logs file
# v 0.02
# code dn365
# include clearlog lib
class Chef::Recipe
  include ClearLog
end


nodes = data_bag_item("logs","nodes")

nodes_hash = data_bag_to_hash(nodes)


rm_arry, archive_arry, cat_arry = [], [],[]
if nodes_hash["#{node.hostname}"]
nodes_hash["#{node.hostname}"].each do |k,v|
  file_path = v["file_path"]
  matches = v["matches"]
  recurse = v["recurse"]
  size = v["file_size"]  
  age = v["age"]    
  operate_type = v["operate_type"]       
  type = v["type"]
  
  fileage = file_age(age.scan(/h|d|w/)[-1], age.scan(/\d+/)[0])
  filesize = size ? file_size(size.scan(/b|k|m|g|t/)[-1], size.scan(/\d+/)[0]) : nil
  files_arry = []
  if recurse(recurse,file_path)
    recurse(recurse,file_path).each{|path| files_arry << matches(path, matches) }
  end
  
  files_arry = files_arry.flatten
  files_age_arry = files_arry.empty? ? false : files_arry.map {|f| f if (Time.now.to_i - file_time(type, f)) > fileage }
  ungzp_arry =  files_age_arry ? files_age_arry.map {|f| f unless f =~ /^.bz2|gz|zip|tar/ } : []
  
  if files_age_arry
    case operate_type
    when 0
      rm = []
      if filesize
        files_age_arry.map {|f| rm << f if f and (File.size(f) > filesize) }
      else
        rm = files_age_arry
      end
      rm_arry << rm
    when 1
      archive = []
      if filesize
        ungzp_arry.map {|f| archive << f if f and (File.size(f) > filesize) }
      else
        archive = ungzp_arry
      end
      archive_arry << archive
    when 2
      cat = []
      if filesize
        ungzp_arry.map {|f| cat << f if f and (File.size(f) > filesize) }
      else
        cat = ungzp_arry
      end     
      cat_arry << cat
    end
  end
end
end

files_hash = {
  "rm" => rm_arry.flatten,
  "archive" => archive_arry.flatten,
  "cat" => cat_arry.flatten
}

directory "/var/chef/exec" do
  action :create
end
unless files_hash["rm"].empty? && files_hash["archive"].empty? && files_hash["cat"].empty?
  template "/var/chef/exec/clean-log-#{Time.now.to_i}.sh" do
    source "clean-log.sh.erb"
    mode 0755
    variables(
      :config_rm => files_hash["rm"],
      :config_archive => files_hash["archive"],
      :config_cat => files_hash["cat"]
      )
  end
end
Dir.glob("/var/chef/exec/*.sh").each do |file|
  if (Time.now.to_i - File.mtime(file).to_i) > 2*(60 **2)
    file "#{file}" do
      action :delete
    end
  end
end

  