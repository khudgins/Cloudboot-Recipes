#
# Cookbook Name:: opennebula
# Recipe:: default
#
# require cloudscaling-drone?
#

include_recipe "gems"

##
## Temporary; needs to move into other modules?
##
%w{ ruby sqlite3 xmlrpc-c openssl ssh ruby-dev make libxml-parser-ruby1.8 libxslt1 libxml2 libxslt1-dev libxml2-dev }.each do |p|
  package p
end

gem_package "nokogiri" do
  action :install
end

include_recipe "opennebula::common"
include_recipe "opennebula::compute-node"
include_recipe "opennebula::cloud-controller"
