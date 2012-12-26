# RcMon

RcMon is a simple process monitoring helper. It helps to ensure processes
stay up and that they are behaving properly. It's simple, straight forward,
and best of all lightweight.

## Overview

The RcMon cookbook provides a definition to configure process monitoring. A
simple definition would look something like:

```ruby
rc_mon_service 'memory_consumer' do
  memory_limit '200M'
  owner 'mem_tester'
  group 'mem_tester'
end
```

By default, RcMon uses runit, which means we'll need to provide templates for
the sv-run and sv-log-run files. We'll keep them simple:

```
# sv-memory_consumer-log-run.erb
#!/bin/sh
exec svlogd -tt ./main
```
```
# sv-memory_consumer-run.erb
#!/bin/sh
exec 2>&1
exec chpst /opt/memory_consumer
```

And some content for the memory consumer script so it actually does something
that needs monitoring:

```ruby
file '/opt/memory_consumer' do
  content "#!#{node[:languages][:ruby][:ruby_bin]}
$a = ['this string was made for clonin']
while(true) do
  $a += $a * 5
  sleep(5)
end
"
  mode 0755
end
```

Now you can watch the process consume memory on the node, and once it has reached
the 200M threshold be killed and auto restarted. 

```bash
$ watch -n 0.5 'ps -AH ux | grep memory_consumer | grep -v grep'
```

## Under the hood

RcMon uses two tools under the hood. Runit is used to keep the process running
and cgroups are used to keep system resources under control. The `rc_mon_service`
definition is simple creating a new cgroup grouping, putting all processes with
the defined owner under that group, and creating a runit service for it. It's
simply a shortcut for something that can be accomplished directly in a recipe
covering only memory restriction and cpu shares.

## Using a different init

If you're using a different init, like upstart, and don't need/want runit to keep
the process alive, just use the `no_runit` argument:

```ruby
rc_mon_service 'memory_consumer' do
  memory_limit '200M'
  owner 'mem_tester'
  group 'mem_tester'
  no_runit true
end
```

## Infos
* Repository: https://github.com/hw-cookbooks/rc_mon
* IRC: Freenode @ #heavywater
