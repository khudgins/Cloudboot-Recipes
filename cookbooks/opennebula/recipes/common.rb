#
# Cookbook Name:: opennebula
# Recipe:: common
#
# require cloudscaling-drone?
#

# Create ONE installdir


directory node[:opennebula][:top_dir] do
  #owner         node[:opennebula][:user][:name]
  #group         node[:opennebula][:user][:primary_group]
  not_if        "test -d #{node[:opennebula][:top_dir]}"
end


group node[:opennebula][:global][:group][:name] do
  gid           node[:opennebula][:global][:group][:id]
end

user node[:opennebula][:user][:name] do
  uid           node[:opennebula][:user][:id]
  gid           node[:opennebula][:global][:group][:id]
  home          node[:opennebula][:user][:home_dir]
#  password      node[:opennebula][:user][:password]
  shell         '/bin/bash'
#  lock          true
#  manage        true
  comment       "OpenNebula User"
end

[ node[:opennebula][:top_dir] ].each do |cloud_dir|
  directory cloud_dir do
    recursive     true
    owner         node[:opennebula][:user][:name]
    group         node[:opennebula][:user][:primary_group]
    not_if        "test -d #{cloud_dir}" || "cat /proc/mounts | grep /srv/cloud"
  end
end






  