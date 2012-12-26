if(node[:rc_mon][:include_runit])
  include_recipe 'runit'
end
include_recipe 'control_groups'
