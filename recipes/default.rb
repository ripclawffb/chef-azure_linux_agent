#
# Cookbook:: azure_pipelines_agent_linux
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

# add gpg key for nodejs yum repo
cookbook_file '/etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL' do
  source 'NODESOURCE-GPG-SIGNING-KEY-EL'
end

# add nodejs yum repo
yum_repository 'Node.js for Enterprise Linux 7 - $basearch - Source' do
  name 'nodesource'
  baseurl 'https://rpm.nodesource.com/pub_10.x/el/7/$basearch'
  failovermethod 'priority'
  enabled true
  gpgcheck true
  gpgkey 'file:///etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL'
end

package 'nodejs'

# add user account to run agent for azure devops
user node['azrdo']['user'] do
  shell '/sbin/nologin'
  system true
  home node['azrdo']['install_dir']
  manage_home false
end

# create install directory
directory node['azrdo']['install_dir'] do
  owner node['azrdo']['user']
  group node['azrdo']['user']
  recursive true
end

# update permissions on work directory
directory "#{node['azrdo']['install_dir']}/_work" do
  owner node['azrdo']['user']
  group node['azrdo']['user']
  recursive true
end

# install git from source
git_client 'source' do
  provider Chef::Provider::GitClient::Source
  source_version '2.26.2'
  source_url 'https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.26.2.tar.gz'
  source_checksum 'e1c17777528f55696815ef33587b1d20f5eec246669f3b839d15dbfffad9c121'
  action :install
end

# install pyenv under user context
pyenv_user_install node['azrdo']['user']

# install various python versions using pyenv
node['azrdo']['python_versions'].each do |python_version|
  pyenv_python python_version do
    user node['azrdo']['user']
  end

  directory "#{node['azrdo']['tool_dir']}/Python/#{python_version}" do
    owner node['azrdo']['user']
    group node['azrdo']['user']
    recursive true
  end

  link "#{node['azrdo']['tool_dir']}/Python/#{python_version}/x64" do
    to "#{node['azrdo']['install_dir']}/.pyenv/versions/#{python_version}"
  end

  file "#{node['azrdo']['tool_dir']}/Python/#{python_version}/x64.complete" do
    owner node['azrdo']['user']
    group node['azrdo']['user']
  end
end

# extract agent install files
tar_extract node['azrdo']['ext_source'] do
  user node['azrdo']['user']
  group node['azrdo']['user']
  target_dir node['azrdo']['install_dir']
  creates "#{node['azrdo']['install_dir']}/env.sh"
  tar_flags [ '--overwrite' ]
  notifies :run, "bash[install azrdo agent dependencies]", :immediate
end

# install azure agent dependencies
bash 'install azrdo agent dependencies' do
  cwd node['azrdo']['install_dir']
  code <<-EOH
    sudo ./bin/installdependencies.sh
  EOH
  action :nothing
  notifies :run, "bash[configure azrdo agent]", :immediate
end

# configure azure agent
bash 'configure azrdo agent' do
  user node['azrdo']['user']
  group node['azrdo']['user']
  cwd node['azrdo']['install_dir']
  code <<-EOH
    ./config.sh --unattended --url '#{node['azrdo']['org_url']}' --auth path --token '#{node['azrdo']['token']}' --acceptTeeEula --pool '#{node['azrdo']['pool']}' --replace
  EOH
  action :nothing
  notifies :run, "bash[install azrdo agent as a service]", :immediate
end

# configure azure agent
bash 'install azrdo agent as a service' do
  cwd node['azrdo']['install_dir']
  code <<-EOH
    sudo ./svc.sh install #{node['azrdo']['user']}
  EOH
  action :nothing
end

# create symbolic link to non-packaged git
link "/bin/git" do
  to "/usr/local/bin/git"
end

# start azure agent
service_name = "vsts.agent.#{node['azrdo']['org_url'].gsub(/.*\//, '')}.#{node['azrdo']['pool']}.#{node['hostname']}.service"
service service_name do
  action :start
end
