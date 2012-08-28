#default



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


  






    
  