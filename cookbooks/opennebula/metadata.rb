maintainer        "Cloudscaling"
maintainer_email  "support@cloudscaling.com"
license           "Apache 2.0 http://www.apache.org/licenses/LICENSE-2.0"
description       "Installs OpenNebula"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "0.1"

%w{ ruby runit }.each do |cb|
  depends cb
end
