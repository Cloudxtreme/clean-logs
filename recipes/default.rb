#
# Cookbook Name:: clean-logs
# Recipe:: default
# system logs clean
# code dn365
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#delete /core*

execut "delete core" do
  command "rm -f #{node["logs"]["core"]} #{Dir.glob("#{node["logs"]["core"]}[/./]*")[0..-1].join(" ")}"
  only_if do
    File.exist?("#{node["logs"]["core"]}")
  end
end

#delete wtmp
# when wtmp > 100MB then delete this file
Dir.glob("#{node["logs"]["wtmp"]}*").each do |w|
  execut "delete wtmp" do
    command "cat /dev/null > #{w}"
    only_if do
      File.size(w) / 1024 > 100 if File.exist?(w)
    end
  end
end

 