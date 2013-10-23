module RcMon
  class << self
    def get_bytes(s)
      s = s.to_s
      indx = [nil, 'k', 'm', 'g']
      power = indx.index(s.slice(-1, s.length).to_s.downcase).to_i * 10
      (2**power) * s.to_i
    end
  end

  module ProviderMethods
    def up_helper(controls, do_action=:create)
      runit_resource = build_runit_resource
      control_dir = ::File.join(runit_resource.sv_dir, runit_resource.service_name, 'control')

      directory control_dir do
        recursive true
      end

      template ::File.join(control_dir, 'u') do
        source 'runit_control_up.erb'
        cookbook 'rc_mon'
        mode 0755
        action do_action
        variables(
          :controls => controls,
          :group => new_resource.group_name
        )
        notifies :restart, build_runit_resource, :delayed
      end
    end

    def build_runit_resource
      unless(@runit_resource)
        @runit_resource = Chef::Resource::RunitService.new(new_resource.name, new_resource.run_context)
        if(new_resource.runit_attributes)
          new_resource.runit_attributes.each do |k,v|
            @runit_resource.send(k, v)
          end
        end
        @runit_resource.action new_resource.action
        @runit_resource.subscribes(:restart,
          new_resource.run_context.resource_collection.lookup(
            'ruby_block[control_groups[write configs]]'
          ), :delayed
        )
        new_resource.run_context.resource_collection << @runit_resource
      end
      @runit_resource
    end

    def configure_cgroups
      if(new_resource.memory_limit)
        mem_limit = RcMon.get_bytes(new_resource.memory_limit)
        memsw_limit = mem_limit + RcMon.get_bytes(new_resource.swap_limit)
      end
      control = []
      if(new_resource.cpu_shares || new_resource.memory_limit)
        control_groups_entry new_resource.group_name do
          if(new_resource.memory_limit)
            memory(
              'memory.limit_in_bytes' => mem_limit,
              'memory.memsw.limit_in_bytes' => memsw_limit
            )
            control << 'memory'
          end
          if(new_resource.cpu_shares)
            cpu 'cpu.shares' => new_resource.cpu_shares
            control << 'cpu'
          end
        end
      end
      control
    end

  end
end
