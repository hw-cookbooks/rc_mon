
define :rc_mon_service, :memory_limit => '100M', :swap_limit => nil, :cpu_shares => nil, :no_runit => false do
  if(params[:owner] == 'root' || params[:owner].to_s.empty?)
    raise 'RCMon will not monitor processes owned by the root user!' unless params[:force_insanity]
  end
  if(params[:memory_limit])
    mem_limit = RcMon.get_bytes(params[:memory_limit])
    memsw_limit = mem_limit + RcMon.get_bytes(params[:swap_limit])
  end
  control = []
  if(params[:cpu_shares] || params[:memory_limit])
    control_groups_entry params[:name] do
      if(params[:memory_limit])
        memory(
          'memory.limit_in_bytes' => mem_limit,
          'memory.memsw.limit_in_bytes' => memsw_limit
        )
        control << 'memory'
      end
      if(params[:cpu_shares])
        cpu 'cpu.shares' => params[:cpu_shares]
        control << 'cpu'
      end
    end

    control_groups_rule params[:owner] do
      controllers %w(cpu memory)
      destination params[:name]
    end
  end

  unless(params[:no_runit])
    runit_attrs = Hash[*(params.map do |key, value|
      unless(%w(name memory_limit swap_limit cpu_shares no_runit).include?(key.to_s))
        [key, value]
      end).flatten.compact
    ]
    runit_service params[:name] do
      runit_attrs.each do |k,v|
        self.send(k, v)
      end
    end
  end
end
