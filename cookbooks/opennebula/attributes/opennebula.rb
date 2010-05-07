##
## Flags Available for Tweaking within this cookbook
## Currently, neither of these do anything.
##
set[:opennebula][:flag][:compile_from_source]     = true
set[:opennebula][:flag][:shared_filesystem]      = true

##
## URLs
##
set[:opennebula][:source]        = "http://dev.opennebula.org/attachments/download/103/one-1.4.0.tar.gz"
## A local http server where large files are located.
set[:opennebula][:localserver]   = "http://10.250.250.42"

##
## Kernel and initrd, should be stored on node[:opennebula][:localserver]
## These files can be found on cloudboot.org - they're a bit large for a git repo
## and you may want to change your boot kernels.
##
set[:opennebula][:xen_domu_kernel] = "vmlinuz-2.6.18-164.6.1.el5xen"
set[:opennebula][:xen_domu_initrd] = "initrd-2.6.18-164.6.1.el5xen.img"

##
## Filesystem Layout
##
set[:opennebula][:top_dir]            = "/srv/cloud"
set[:opennebula][:image_dir]            = "/srv/cloud/images"
##
## Groups & Users
##
set[:opennebula][:global][:group][:name]  = "cloud"
set[:opennebula][:global][:group][:id]    = 2001
set[:opennebula][:user][:name]            = "oneadmin"
set[:opennebula][:user][:id]              = 2001
set[:opennebula][:user][:primary_group]   = "cloud"
set[:opennebula][:user][:home_dir]        = "/srv/cloud/one"
set[:opennebula][:user][:password]        = "cloud"

##
## Set these addresses to fit your environment.
## the controller ip address is the assigned address to your
## ONE host.
## localnet is your local network's full network address and netmask,
## used for the /etc/exports template.
##
set[:opennebula][:controller][:ip_address] = "192.168.0.5"
set[:opennebula][:network][:localnet][:address] = "192.168.0.0"
set[:opennebula][:network][:localnet][:netmask] = "255.255.255.255"


##
## One Network IP addresses
## Just put them in an array for
## template. Currently, I'm using external DHCP for my
## VM Images.
##
set[:opennebula][:network][:name] = "Initial network"
set[:opennebula][:network][:bridge] = "xenbr0"
set[:opennebula][:network][:addresses] = ["10.250.250.180", "10.250.250.181", "10.250.250.182", "10.250.250.183","10.250.250.184", "10.250.250.185"]