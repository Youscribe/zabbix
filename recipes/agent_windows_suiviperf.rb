include_recipe "chocolatey"

chocolatey "zabbix-agent"

service "zabbix_agentd" do
  service_name "Zabbix Agent"
  provider Chef::Provider::Service::Windows
  supports :restart => true
  action [ :enable, :start ]
end

template "C:/Program Files/Zabbix Agent/zabbix_agentd.conf" do
  source "zabbix_agentd.conf.erb"
  notifies :restart, "service[zabbix_agentd]"
end
