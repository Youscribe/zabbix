require 'open-uri'

def whyrun_supported?
  true
end

action :import do
	converge_by("Importing object '#{new_resource.name}'") do
	  import()
	end
	new_resource.updated_by_last_action(true)
end

def import()
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
  
  unless new_resource.url.nil?
    Chef::Log.info("Loading data from '#{new_resource.url}'")
    open(new_resource.url) do |f|
      new_resource.content = f.read
    end
  end

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    connection.configurations.import(:format => new_resource.format,
    :rules => {
        new_resource.type => {
            :createMissing => true,
            :updateExisting => true
        }
    },
	:source => new_resource.content)
  end
end
