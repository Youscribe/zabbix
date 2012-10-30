# Author:: Guilhem Lettron (<guilhem.lettron@youscribe.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_registration
#
# Apache 2.0
#

c = cookbook_file "zabbixapi.gem" do
  source "zabbixapi.gem"
  path "#{Chef::Config[:file_cache_path]}/zabbixapi.gem"
  unless node['plateform'] == "windows" 
    mode "0644"
  end
  action :create
  notifies :install, "gem_package[zabbixapi]"
end

# find it here : https://github.com/Youscribe/zabbixapi
# TODO check here : https://github.com/xeron/zabbixapi if pull request have been accept and upload in rubygem
g = gem_package "zabbixapi" do
  source "#{Chef::Config[:file_cache_path]}/zabbixapi.gem"
  action :nothing
  options("--force --prerelease")
  notifies :delete, "cookbook_file[zabbixapi.gem]"
  only_if {File.exists?("#{Chef::Config[:file_cache_path]}/zabbixapi.gem")}
end

c.run_action(:create)
g.run_action(:install)

Gem.clear_paths
require 'zabbixapi'

class Chef::Recipe
  include TcpPortOpen
end

zabbixServer = search(:node, "recipes:zabbix\\:\\:server").first
if port_open?(zabbixServer['zabbix']['web']['fqdn'], 80)

  zbx = Zabbix::ZabbixApi.new("http://#{zabbixServer['zabbix']['web']['fqdn']}/api_jsonrpc.php",zabbixServer['zabbix']['web']['login'],zabbixServer['zabbix']['web']['password'])

  ruby_block "add chef-agent group" do
    block do
      zbx.add_group("chef-agent")
    end
    not_if { zbx.get_group_id("chef-agent") }
  end

  ruby_block "register agent" do
    block do
      group = zbx.get_group_id("chef-agent").to_i
      host_options = {
        'host' => node['zabbix']['agent']['hostname'],
        'interfaces' => [ { "type" => 1, "main" => 1, "useip" => 0, "ip" => "", "dns" => node['fqdn'], "port" => 10050 } ],
        'templates' => [],
        'groups' => [ group ]
      }
      zbx.add_host( host_options )
    end
    not_if { zbx.get_host_id(node['zabbix']['agent']['hostname']) }
  end
end
