include ::RcMon::ProviderMethods

def load_current_resource
  new_resource.runit_name new_resource.name unless new_resource.runit_name
  new_resource.group_name new_resource.name unless new_resource.group_name
end

action :enable do
  @runit_resource = new_resource.run_context.resource_collection.lookup("runit_service[#{new_resource.runit_name}]")
  controls = configure_cgroups
  up_helper(controls)
end

action :disable do
  @runit_resource = new_resource.run_context.resource_collection.lookup("runit_service[#{new_resource.runit_name}]")
  up_helper([], :delete)
end
