apt_update 'update'

package 'ncdu'

include_recipe 'chef_wordpress::debug'
include_recipe 'chef_wordpress::generate_bootstrap'
include_recipe 'streambox_mail::default'
include_recipe 'prometheus-platform::default'

include_recipe 'chef_wordpress::hosts'
include_recipe 'fail2ban::default'
include_recipe 'chef_wordpress::fail2ban'

include_recipe 'acme'
include_recipe 'htop'
include_recipe 'cloudcli::default'
include_recipe 'chef_wordpress::aws_cli'

include_recipe 'chef_wordpress::php'
include_recipe 'php::module_mysql'

include_recipe 'chef_wordpress::nginx'

include_recipe 'cron::default'

include_recipe 'chef_wordpress::mysql_client'
include_recipe 'chef_wordpress::wordpress'
include_recipe 'chef_wordpress::wordpress_plugins'
include_recipe 'chef_wordpress::certbot'
include_recipe 'chef_wordpress::w3tc_cache'
include_recipe 'chef_wordpress::wpuser'
include_recipe 'chef_wordpress::add_git_backup'
include_recipe 'chef_wordpress::add_s3_backup'
include_recipe 'chef_wordpress::wp_permissions'

# fails for amazon and suse and haven't found benefit from optipng or jpegoptim
# include_recipe 'chef_wordpress::images'
