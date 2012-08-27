maintainer       "dn365"
maintainer_email "dn@365"
license          "All rights reserved"
description      "Installs/Configures clean-logs"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w[ ubuntu hpux aix centos redhat ].each do |os|
  supports os
end
