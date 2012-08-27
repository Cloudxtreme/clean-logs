require "rbconfig"
default["logs"]["syslogs"] = ["/var/log/syslog"]
default["logs"]["core"] = "/core"


# Data retention days
default["logs"]["time"] = 5

case os
when "linux"
  default["logs"]["wtmp"] = "/var/log/wtmp"
when "aix"
  default["logs"]["wtmp"] = "/var/adm/wtmp"
when "hpux"
  default["logs"]["wtmp"] = "/var/adm/wtmp"
end


