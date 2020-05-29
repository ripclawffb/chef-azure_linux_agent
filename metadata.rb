name 'azure_pipelines_agent_linux'
maintainer 'Asif Shaikh'
maintainer_email 'ripclaw_ffb@hotmail.com'
license 'All Rights Reserved'
description 'Installs/Configures azure_pipelines_agent_linux'
version '0.1.0'
chef_version '>= 14.0'

depends 'git'
depends 'nodejs'
depends 'pyenv'
depends 'tar'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
issues_url 'https://github.com/ripclaw_ffb/chef-azure_pipelines_agent_linux/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
source_url 'https://github.com/ripclaw_ffb/chef-azure_pipelines_agent_linux'
