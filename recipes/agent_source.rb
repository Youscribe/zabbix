# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_source
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe "zabbix::agent_conf"

case node['platform']
when "ubuntu","debian"
  # install some dependencies
  %w{ fping libcurl3 libiksemel-dev libiksemel3 libsnmp-dev libiksemel-utils libcurl4-openssl-dev }.each do |pck|
    package pck do
      action :install
    end
  end
  init_template = 'zabbix_agentd.init.erb'
  
when "redhat","centos","scientific","amazon"
    %w{ fping curl-devel iksemel-devel iksemel-utils net-snmp-libs net-snmp-devel openssl-devel redhat-lsb }.each do |pck|
      package pck do
        action :install
      end
    end
  init_template = 'zabbix_agentd.init-rh.erb'
end

# --prefix is controlled by install_dir
configure_options = (node['zabbix']['agent']['configure_options'] || Array.new).delete_if do |option|
  option.match(/\s*--prefix(\s|=).+/)
end

ark "zabbix_agent" do
  url "http://downloads.sourceforge.net/project/zabbix/#{node['zabbix']['agent']['branch']}/#{node['zabbix']['agent']['version']}/zabbix-#{node['zabbix']['agent']['version']}.tar.gz"
  autoconf_opts ["--enable-agent" ] + configure_options.join(" ")
  action [ :configure, :install_with_make ]
end
