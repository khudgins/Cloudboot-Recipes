#
# Cookbook Name:: opennebula
# Recipe:: cloud-controller
#
include_recipe "opennebula::common"

[ node[:opennebula][:image_dir], node[:opennebula][:user][:home_dir] ].each do |cloud_dir|
  directory cloud_dir do
    recursive     true
    owner         node[:opennebula][:user][:name]
    group         node[:opennebula][:user][:primary_group]
    not_if        "test -f #{cloud_dir}" || "cat /proc/mounts | grep /srv/cloud"
  end
end

# Set up all files required for oneadmin system user

["#{node[:opennebula][:user][:home_dir]}/.ssh", "#{node[:opennebula][:user][:home_dir]}/.one" ].each do |dot_dir|
  directory dot_dir do
    action :create
    mode "0700"
    owner node[:opennebula][:user][:id]
    group node[:opennebula][:global][:group][:id]
  end
end

remote_file "#{node[:opennebula][:user][:home_dir]}/.ssh/id_rsa" do
  action :create
  source "id_rsa"
  owner node[:opennebula][:user][:id]
  group node[:opennebula][:global][:group][:id]
  mode "0600"
end

remote_file "#{node[:opennebula][:user][:home_dir]}/.ssh/authorized_keys" do
  action :create
  source "id_rsa.pub"
  owner node[:opennebula][:user][:id]
  group node[:opennebula][:global][:group][:id]
  mode "0600"
end

remote_file "#{node[:opennebula][:user][:home_dir]}/.ssh/config" do
  action :create
  source "ssh_config"
  owner node[:opennebula][:user][:id]
  group node[:opennebula][:global][:group][:id]
  mode "0600"
end

template "#{node[:opennebula][:user][:home_dir]}/.one/one_auth" do
  source "one_auth.erb"
  mode 0600
  owner node[:opennebula][:user][:id]
  group node[:opennebula][:global][:group][:id]
end

template "#{node[:opennebula][:user][:home_dir]}/.bashrc" do
  source "bashrc.erb"
  mode 0644
  owner node[:opennebula][:user][:id]
  group node[:opennebula][:global][:group][:id]
end

remote_file "#{node[:opennebula][:user][:home_dir]}/.bash_profile" do
  source "bash_profile"
  mode 0644
  owner node[:opennebula][:user][:id]
  group node[:opennebula][:global][:group][:id]
end

# Note: These packages are ubuntu/debian specific!!
["libxml2", "libxml2-dev", "libxslt1.1", 
  "libxslt1-dev", "libexpat1", "libexpat1-dev", 
  "rake", "scons", "pkg-config",
  "libsqlite3-dev", "libxmlrpc-c3-dev", "g++",
  "libssl-dev", "portmap", "nfs-kernel-server"
  
  ].each do |install_package|
  package install_package do
    action :install
  end
end

# NFS config for this guy. Probably should be broken out somewhere later:
service "portmap" do
  action :start
end

template "/etc/exports" do
  source "exports.erb"
  mode 0644
end

service "nfs-kernel-server" do
  supports :restart => true
  action :start
  subscribes :restart, resources(:template => "/etc/exports")
end


# Hack to fix rake bug in debian/ubuntu:
# See http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=529663
link "/usr/bin/rake1.8" do 
  to "/usr/bin/rake"
end

["nokogiri", "xmlparser"].each do |install_gem|
  gem_package install_gem do
    action :install
  end
end

# Hokay, let's do this biznitch:

#remote_file "/tmp/opennebula.tar.gz" do
#  source node[:opennebula][:source]
#  mode "0644"
#end

script "install_opennebula" do
  interpreter "bash"
  cwd "/tmp"
  not_if "ls #{node[:opennebula][:user][:home_dir]}/bin"
  code <<-EOH
  wget #{node[:opennebula][:source]}
  tar xzvf one-1.4.0.tar.gz
  cd one-1.4
  scons -j2
  ./install.sh -u #{node[:opennebula][:user][:name]} -g #{node[:opennebula][:global][:group][:name]} -d #{node[:opennebula][:user][:home_dir]}
  EOH
end

# Now, we overwrite the startup script with a modified version
# to handle the install location and setu/gid:

template "#{node[:opennebula][:user][:home_dir]}/bin/one" do
  source "one_startup.erb"
  mode 0755
  owner node[:opennebula][:user][:id]
  group node[:opennebula][:global][:group][:id]
end

template "#{node[:opennebula][:user][:home_dir]}/etc/oned.conf" do
  source "oned.conf.erb"
  mode 0644
  owner node[:opennebula][:user][:id]
  group node[:opennebula][:global][:group][:id]
end

template "#{node[:opennebula][:user][:home_dir]}/etc/one_network.net" do
  source "one_network.net.erb"
  mode 0644
  owner node[:opennebula][:user][:id]
  group node[:opennebula][:global][:group][:id]
  variables(
    :ip_addresses => node[:opennebula][:network][:addresses]
  )
end

template "#{node[:opennebula][:user][:home_dir]}/etc/vm_definition.one" do
  source "vm_definition.one.erb"
  mode 0644
  owner node[:opennebula][:user][:id]
  group node[:opennebula][:global][:group][:id]
  variables(
    :os_image_file => "centos_5.4.img"
  )
end

link "/etc/init.d/one" do
  to "#{node[:opennebula][:user][:home_dir]}/bin/one"
  link_type :symbolic
end



service "one" do
  action [:enable, :start]
end

##
## Create vnet in ONE based upon the one_network template
## HACK ALERT: I'm touching a file to make sure we only run this once.
## There should be a better way.
## Currently disabled until I figure out how to get a ruby script to
## run inside a shell script inside a chef run.
bash "create vnet and cloud hosts" do
  user "oneadmin"
  code <<-EOH
  export ONE_LOCATION=/srv/cloud/one
  export ONE_AUTH=/srv/cloud/one/.one/one_auth
  export ONE_XMLRPC=http://localhost:2633/RPC2
  export PATH=$ONE_LOCATION/bin:$PATH
  /srv/cloud/one/bin/onevnet create /srv/cloud/one/etc/one_network.net
  touch #{node[:opennebula][:user][:home_dir]}/etc/net_created
  /srv/cloud/one/bin/onehost create cnode1.cloudscaling.com
  /srv/cloud/one/bin/onehost create cnode2.cloudscaling.com
  cp /srv/tmp/centos.5-4.x86-64.img /srv/cloud/images/centos.5-4.x86-64.img
  
  EOH
  not_if "test -f #{node[:opennebula][:user][:home_dir]}/etc/net_created"
end




