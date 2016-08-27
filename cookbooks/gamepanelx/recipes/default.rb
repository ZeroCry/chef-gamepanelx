#
# Cookbook Name:: gamepanelx
# Recipe:: default
#
# Copyright 2016, GamePanelX
# Written by Ryan Gehrig
# August 2016
#
# License: GNU General Public License V2.0
#
case node['platform_family']
  when 'rhel','fedora'
    pkgs = [ 'screen','glibc.i686','libstdc++.i686','libgcc_s.so.1','libgcc.i686','java','wget','unzip','expect','rabbitmq-server' ]
  when 'debian'
    pkgs = [ 'lib32bz2','lib32ncurses5','lib32tinfo5','lib32z1','libc6','libstdc++6','expect','rabbitmq-server' ]
  else
    raise('This module does not support this OS.  You must ensure your own dependencies are setup!')
end

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

# Install/setup MySQL
package 'mysql' do
  action :install
end
service 'mysql' do
  action [ :enable, :start ]
  notifies :run, 'execute[Setup Mysql Server]', :delayed
end

cookbook_file '/tmp/secure_mysql.sh' do
  owner 'root'
  group 'root'
  mode 0755
  source 'mysql_secure.sh'
  action :create
end
execute 'Setup Mysql Server' do
  user 'root'
  cwd '/tmp'
  command './mysql_secure.sh'
  action :nothing
end

service "httpd" do
  action [ :enable, :start ]
end
