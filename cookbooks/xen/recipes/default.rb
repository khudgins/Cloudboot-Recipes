#
# Cookbook Name:: xen
# Recipe:: default
#
# Copyright 2010, cloudscaling.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

## Notice!
# This recipe does NOT reboot the node post-application.
# In order to run Xen, you must reboot once this recipe runs
# the first time. 

case node[:platform]
when "centos", "redhat", "fedora"
  # Using the gitco repo for xen 3.4.2
  remote_file "/etc/yum.repos.d/gitco.repo" do
    source "http://www.gitco.de/linux/x86_64/centos/5/CentOS-GITCO.repo"
    mode "0644"
    checksum "3efeb11d9b0057eef9d9184c900140782b959524b5f2e16a694a7c27fea74635"
  end
  # Install packages
  ["xen", "kernel-xen", "virt-manager","virt-viewer", "libvirt"  ].each do |install_package|
    package install_package do
      action :install
    end
    
  end
  ### HACK WARNING!!!
  ## If Gitco updates their kernel version, this WILL cause the subsequent reboot
  ## to hose your system!!! 
  template "/etc/grub.conf" do
    mode "0644"
    source "grub.conf.erb"
    
  end
when "ubuntu"
  # We're assuming Ubuntu, most probably >= 8.04 here. Testing on 9.10
  package "ubuntu-xen-server" do
    action :install
  end
end

service "xend" do
  action [:enable]
  supports :restart => true
end

template "/etc/xen/xend-config.sxp" do
  source "xend-config.sxp.erb"
  mode "0644"
  notifies :restart, resources(:service => "xend")
end

directory "/etc/xen" do
  mode "0755"
end

# Add more loopback interfaces, just in case. I'm echoing this instead of using a file
# So as ao lighten the impact on any other changes
# Also, set up xenbr0 virtual bridge and vnet on eth0:
#script "set_up_networking" do
#  interpreter "bash"
#  cwd "/tmp"
#  code <<-EOH
#    echo "loop max_loop=64 >> /etc/modules"
#    vconfig add eth0 0
#    brctl addbr xenbr0
#    brctl addif xenbr0 eth0.0
#    ifconfig  eth0.0 up
#    ifconfig xenbr0 up
#  EOH
#end


