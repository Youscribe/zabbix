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
  
  content = new_resource.content 
  unless new_resource.url.nil?
    Chef::Log.info("Loading data from '#{new_resource.url}'")
    open(new_resource.url) do |f|
       content = f.read
    end
  end

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    connection.configurations.import(:format => new_resource.format,
    :rules => {
        :applications => {
            :createMissing => true,
            :updateExisting => true
        },
        :discoveryRules => {
            :createMissing => true,
            :updateExisting => true
        },
        :graphs => {
            :createMissing => true,
            :updateExisting => true
        },
        :groups => {
            :createMissing => true,
            :updateExisting => true
        },
        :images => {
            :createMissing => true,
            :updateExisting => true
        },
        :items => {
            :createMissing => true,
            :updateExisting => true
        },
        :maps => {
            :createMissing => true,
            :updateExisting => true
        },
        :screens => {
            :createMissing => true,
            :updateExisting => true
        },
        :templateLinkage => {
            :createMissing => true,
            :updateExisting => true
        },
        :templates => {
            :createMissing => true,
            :updateExisting => true
        },
        :templateScreens => {
            :createMissing => true,
            :updateExisting => true
        },
        :triggers => {
            :createMissing => true,
            :updateExisting => true
        }
    },
	:source => content)
  end
end
