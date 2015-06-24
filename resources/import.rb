actions :import
default_action :import

attribute :format, :kind_of => String, :default => 'xml'
attribute :type, :kind_of => String, :required => true
attribute :url, :kind_of => String, :name_attribute => false
attribute :content, :kind_of => String, :name_attribute => false
attribute :server_connection, :kind_of => Hash, :default => {}
