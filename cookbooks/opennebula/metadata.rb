maintainer        "neoTactics, Inc DBA Cloudscaling"
maintainer_email  "support@cloudscaling.com"
license           "Drone (Blank) Role"
description       "Installs and configures minimal set of common configurations for a basic server"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "0.1"

%w{ ruby runit }.each do |cb|
  depends cb
end
