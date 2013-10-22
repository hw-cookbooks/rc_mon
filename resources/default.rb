actions :enable, :disable
default_action :enable

attribute :runit_name, :kind_of => String, :required => true, :name_attribute => true
attribute :group_name, :kind_of => String
attribute :memory_limit, :kind_of => [String,Numeric]
attribute :swap_limit, :kind_of => [String,Numeric]
attribute :cpu_shares, :kind_of => Numeric
