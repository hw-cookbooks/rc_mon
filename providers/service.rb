include ::RcMon::ProviderMethods

def load_current_resource
  new_resource.group_name new_resource.name unless new_resource.group_name
end

RUNIT_ACTIONS = Chef::Resource::RunitService.new('rc_mon').instance_variable_get(:@allowed_actions).each do |action_name|
  action action_name.to_sym do
    controls = configure_cgroups
    runit_resource = build_runit_resource
    up_helper(controls)
  end
end
