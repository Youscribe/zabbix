# Author:: Guilhem Lettron (<guilhem.lettron@youscribe.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_registration
#
# Apache 2.0
#

chef_gem "zabbixapi" do
  action :upgrade
  version "~> 0.5"
end

require 'zabbixapi'

zabbixServer = search(:node, "recipes:zabbix\\:\\:server").first
if port_open?(zabbixServer['zabbix']['web']['fqdn'], 80)

  zbx = ZabbixApi.connect(
    :url => "http://#{zabbixServer['zabbix']['web']['fqdn']}/api_jsonrpc.php",
    :user => zabbixServer['zabbix']['web']['login'],
    :password => zabbixServer['zabbix']['web']['password']
  )

  ruby_block "add chef-agent group" do
    block do
      zbx.hostgroups.create(
        :host => "chef-agent"
      )
    end
    not_if { zbx.hostgroups.get_id(:name => "chef-agent") }
  end

  ruby_block "register agent" do
    block do
      zbx.hosts.create_or_update(
        :host => node['zabbix']['agent']['hostname'],
        :usedns => true,
        :groups => [ :groupid => zbx.hostgroups.get_id(:name => "chef-agent") ]
      )
    end
  end
end
