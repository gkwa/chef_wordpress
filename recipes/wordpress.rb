wordpress_creds = data_bag_item('secrets', 'wordpress')
database_creds = data_bag_item('secrets', 'database_creds')

directory node['chef_wordpress']['wordpress_root'] do
  recursive true
end

nginx_site 'Enable the wordpress_site' do
  template 'site_wordpress.erb'
  name 'wordpress_site'
  action :enable # modern action
end

remote_file "#{Chef::Config['file_cache_path']}/wordpress-latest.tar.gz" do
  source 'https://wordpress.org/latest.tar.gz'
end

bash 'deploy wordpress' do
  code <<-EOS
    tar xzf #{Chef::Config['file_cache_path']}/wordpress-latest.tar.gz --strip-components=1 -C "#{node['chef_wordpress']['wordpress_root']}"
  EOS
  not_if { ::File.exist?("#{node['chef_wordpress']['wordpress_root']}/wp-config.php") }
end

template "#{node['chef_wordpress']['wordpress_root']}/salt.php" do
  source 'salt.php.erb'
  variables(
    salt_constants: lazy { shell_out('curl -sS https://api.wordpress.org/secret-key/1.1/salt/').stdout }
  )
  sensitive true
  not_if { ::File.exist?("#{node['chef_wordpress']['wordpress_root']}/salt.php") }
end

template "#{node['chef_wordpress']['wordpress_root']}/wp-config.php" do
  source 'wp-config.php.erb'
  sensitive true
  variables(
    wp_debug:                   node['chef_wordpress']['wp_debug'],
    wp_debug_log:               node['chef_wordpress']['wp_debug_log'],
    wp_debug_display:           node['chef_wordpress']['wp_debug_display'],
    wp_script_debug:            node['chef_wordpress']['wp_script_debug'],
    wp_auto_update_core:        node['chef_wordpress']['wp_auto_update_core'],
    wp_disallow_file_mods:      node['chef_wordpress']['wp_disallow_file_mods'],
    fqdn:                       node['fqdn'],
    dns_aws_access_key_id:      wordpress_creds[node.chef_environment]['dns_aws_access_key_id'],
    dns_aws_secret_access_key:  wordpress_creds[node.chef_environment]['dns_aws_secret_access_key'],
    db_name:                    database_creds[node.chef_environment]['db_name'],
    db_user:                    database_creds[node.chef_environment]['db_user'],
    db_password:                database_creds[node.chef_environment]['db_password'],
    db_host:                    node['db_endpoint'].split(':')[0],
    db_port:                    node['db_endpoint'].split(':')[1]
  )
end

ruby_block "Installing Wordpress for site \"#{node['chef_wordpress']['wordpress_title']}\"" do
  install = %W{
    /usr/local/bin/wp
    --path=#{node['chef_wordpress']['wordpress_root']}
    --url=#{node['chef_wordpress']['wordpress_url']}
    --title="#{node['chef_wordpress']['wordpress_title']}"
    --admin_user=#{wordpress_creds[node.chef_environment]['wordpress_admin_user']}
    --admin_password="#{wordpress_creds[node.chef_environment]['wordpress_admin_password']}"
    --admin_email="#{wordpress_creds[node.chef_environment]['wordpress_admin_email']}"
    core install
  }.join(' ')

  Chef::Log.info("install cmd: #{install}")

  block do
    shell_out!(install)
  end

  not_if "/usr/local/bin/wp --path=#{node['chef_wordpress']['wordpress_root']} core is-installed"
end
