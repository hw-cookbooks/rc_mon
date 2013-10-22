include RcMon::Provider

def load_current_resource
  new_resource.group_name new_resource.name unless new_resource.group_name
end

action :enable do
  @runit_service = new_resource.run_context.cookbook_collection.lookup("runit_service[#{new_resource.runit_name}]")
  controls = configure_cgroups
  up_helper(controls)
end

action :disable do
  @runit_service = new_resource.run_context.cookbook_collection.lookup("runit_service[#{new_resource.runit_name}]")
  up_helper([], :delete)
end
