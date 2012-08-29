#default

#custom


# matches
def matches(path,matches)
  file_arry = []
  Dir[path].each do |file_path|
    unless File.directory?(file_path)
      basename = File.basename(file_path)
      flags = File::FNM_DOTMATCH | File::FNM_PATHNAME
      if matches.find {|f| File.fnmatch(f, basename, flags)}
        file_arry << file_path
      end
    end
  end
  return file_arry unless file_arry.empty?
end

#recurse path
def recurse(path,file_path)
  @recurse = {
    0 => "*",
    1 => "*/*",
    2 => "*/*/*",
    3 => "**"
  }
  @recurse[4] = "#{file_path}/#{@recurse[0]}"
  @recurse[5] = "#{file_path}/#{@recurse[1]}"
  @recurse[6] = "#{file_path}/#{@recurse[2]}"
  @recurse[7] = "#{file_path}/#{@recurse[3]}"
  case path
  when 0
    filepath = ["#{@recurse[4]}"]
    return filepath
  when 1
    filepath = ["#{@recurse[4]}","#{@recurse[5]}"]
    return filepath
  when 2
    filepath = ["#{@recurse[4]}","#{@recurse[5]}","#{@recurse[6]}"]
    return filepath
  when 3
    filepath = ["#{@recurse[7]}"]
    return filepath
  else
    puts "Not find #{file_path}"
  end
end

# file size
def file_size(unit, multi)
  @sizeconvertors = {
        "b" => 0,
        "k" => 1,
        "m" => 2,
        "g" => 3,
        "t" => 4
      }
  if %w[b k m g t].include?(unit)
    num = @sizeconvertors["#{unit}"]
    result = multi.to_i
    num.times do result *= 1024 end
    return result
  else
    return false
  end
end

# files age
def file_age(unit, multi)
  @ageconvertors = {
        :s => 1,
        :m => 60
      }
  @ageconvertors["h"] = @ageconvertors[:m] * 60
  @ageconvertors["d"] = @ageconvertors["h"] * 24
  @ageconvertors["w"] = @ageconvertors["d"] * 7
  
  if num = @ageconvertors[unit]
    return num * multi.to_i
  else
    puts "Invalid age unit '#{unit}'"
  end
end

def file_time(time,path)
  # 0 => ctime
  # 1 => mtime 
  # 2 => atime
  case time
  when 0
    return File.ctime(path).to_i
  when 1
    return File.mtime(path).to_i
  when 2
    return File.atime(path).to_i
  end
end

#logs = data_bag("logs")
nodes = data_bag_item("logs","nodes")
node_logs_arry = []
nodes.each do |log_node, value|
  if log_node == node.hostname
    value.each do |num,values|
      file_path = values["file_path"]
      matches = values["matches"]
      recurse = values["recurse"]
      size = values["file_size"]  
      age = values["age"]
          
      operate_type = values["operate_type"] #0 rm 1 gzp
         
      type = values["type"]
      
      
     fileage = file_age(age.scan(/h|d|w/)[-1], age.scan(/\d+/)[0])
     filesize = file_size(size.scan(/b|k|m|g|t/)[-1], size.scan(/\d+/)[0])
     
      
      recurse(recurse,file_path).each do |path|
        file = matches(path, matches)
        unless file == nil
          case operate_type
          when 0 #rm
            farry = []
            file.map {|f| farry << f if (Time.now.to_i - file_time(type, f)) > fileage }
            
            if filesize
              fa = []
              farry.map {|f| fa << f if File.size(f) > filesize }            
              node_logs_arry << {"rm"=> fa} unless fa.empty?
            else
              #puts "rm tytyty #{farry}"
              node_logs_arry << {"rm"=> farry } unless farry.empty?
            end
          when 1 #gzip
            gzip_type,gtype = [],[]
            file.map {|f| gzip_type << f if (Time.now.to_i - file_time(type, f)) > fileage }
            gzip_type.map {|f| gtype << f unless f =~ /^.bz2|gz|zip|tar/ }
            if filesize
              hh = []
              gtype.map {|f| hh << f if File.size(f) > filesize }
              node_logs_arry << {"archive"=> hh} unless hh.empty?
            else
              #puts "#{gtype}"
              node_logs_arry << {"archive"=> gtype} unless gtype.empty?
            end
          end
        end
      end

    end
  end
end
rm_arry,archive_arry = [],[]
node_logs_arry.each do |you|
  you.each do |key,value|
    if key == "rm"
      rm_arry << value
    else
      archive_arry << value
    end
  end
end


unless rm_arry.flatten!.empty? || archive_arry.flatten!.empty?
  directory "/var/chef/exec" do
    action :create
  end
  template "/var/chef/exec/clean-log.sh" do
    source "clean-log.sh.erb"
    mode 0755
    variables(
        :config_rm => rm_arry.flatten!,
        :config_archive => archive_arry.flatten!
      )
  end
end

  






    
  