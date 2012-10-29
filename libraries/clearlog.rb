module ClearLog
  
  def data_bag_to_hash(bag_item)
    node_hash = {}
    bag_item.each do |log_node, value|
      if log_node != "id"
        node_hash[log_node] = value.each do |num,values|
          {
            "file_path" => values["file_path"],
            "matches" => values["matches"],
            "recurse" => values["recurse"],
            "size" => values["file_size"],
            "age" => values["age"],
            "operate_type" => values["operate_type"],
            "type" => values["type"]
          }
        end
      end
    end
    return node_hash
  end
  
  
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
    return file_arry #unless file_arry.empty?
  end

  #recurse path
  def recurse(path,file_path)
    @recurse = {
      0 => "*",
      1 => "*/*",
      2 => "*/*/*",
      3 => "**/*"
    }
    @recurse[4] = "#{file_path}/#{@recurse[0]}"
    @recurse[5] = "#{file_path}/#{@recurse[1]}"
    @recurse[6] = "#{file_path}/#{@recurse[2]}"
    @recurse[7] = "#{file_path}/#{@recurse[3]}"
    
    case path
    when 0
      filepath = ["#{@recurse[4]}"]
    when 1
      filepath = ["#{@recurse[4]}","#{@recurse[5]}"]
    when 2
      filepath = ["#{@recurse[4]}","#{@recurse[5]}","#{@recurse[6]}"]
    when 3
      filepath = ["#{@recurse[7]}"]
    else
      filepath = false
    end
    return filepath
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
      return false
    end
  end

  def file_time(time,path)
    # 0 => ctime
    # 1 => mtime 
    # 2 => atime
    case time
    when 0
      filetime = File.ctime(path).to_i
    when 1
      filetime = File.mtime(path).to_i
    when 2
      filetime = File.atime(path).to_i
    end
    return filetime.to_i
  end
  
end