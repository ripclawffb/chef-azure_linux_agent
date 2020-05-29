return unless node['os'] == 'linux'

default['azrdo']['user'] = 'azrdo'
default['azrdo']['install_dir'] = '/data/azrdo'
default['azrdo']['tool_dir'] = '/data/azrdo/_work/_tool'
default['azrdo']['ext_source'] = 'https://vstsagentpackage.azureedge.net/agent/2.168.2/vsts-agent-linux-x64-2.168.2.tar.gz'

default['azrdo']['local_source'] = '/tmp/vsts-agent-linux-x64-2.168.2.tar.gz'
default['azrdo']['python_versions'] = ['3.8.2']
default['azrdo']['pool'] = 'Linux'
