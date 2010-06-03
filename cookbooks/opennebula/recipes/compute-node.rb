#
# Cookbook Name:: opennebula
# Recipe:: compute-node
#

# Note: You will need a hypervisor on the same node you run this recipe.
#       Add that hypervisor recipe to a role definition with this one.

include_recipe "opennebula::common"

# Make sure the top_dir is created. It already should be, but with idempotence, this doesn't hurt.
directory node[:opennebula][:top_dir] do
  recursive     true
  owner         node[:opennebula][:user][:name]
  group         node[:opennebula][:user][:primary_group]
  not_if        "test -d #{node[:opennebula][:top_dir]}"
end
# Make sure the directories *below* the top_dir are _not_ created. The common recipe
# requires them for the creation of the oneadmin user, which we need.
[ node[:opennebula][:image_dir], node[:opennebula][:user][:home_dir] ].each do |cloud_dir|
  directory cloud_dir do
    recursive     true
    action :delete
    not_if "cat /proc/mounts | grep /srv/cloud"
  end
end

# this is in array form 'cause I cut-and-pasted, and I may wanna install more
# here anyway.
if node[:platform] == "ubuntu"
  ["nfs-common"].each do |install_package|
    package install_package do
      action :install
    end
  end
end
controller_attributes = search(:node, "role:cloud-controller") # Better roles will be defined later

mount node[:opennebula][:top_dir] do
  fstype "nfs"
  options "proto=tcp"
  # Hack, I should make sure there's only one address in the search above here.
  #device "#{controller_attributes[0][0][:ipaddress]}:#{node[:opennebula][:image_dir]}"
  # More hack, search doesn't work in Randy's environment, so this is in attributes.
  device "#{node[:opennebula][:controller][:ip_address]}:#{node[:opennebula][:top_dir]}"
end

# Drop the xen vm kernel and initrd in /boot:
remote_file "/boot/#{node[:opennebula][:xen_domu_kernel]}" do
  source "#{node[:opennebula][:localserver]}/#{node[:opennebula][:xen_domu_kernel]}"
  mode "0644"
end

remote_file "/boot/#{node[:opennebula][:xen_domu_initrd]}" do
  source "#{node[:opennebula][:localserver]}/#{node[:opennebula][:xen_domu_initrd]}"
  mode "0644"
end

template "/etc/sudoers" do
  source "sudoers.erb"
  mode "0440"
end