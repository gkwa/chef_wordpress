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

directory "#{ENV['HOME']}/.wp-cli" do
  mode 0o700
end

template "#{ENV['HOME']}/.wp-cli/config.yml" do
  source '.wp-cli-config.yml.erb'
  sensitive true
  variables(
    dbname:   database_creds[node.chef_environment]['db_name'],
    dbuser:   database_creds[node.chef_environment]['mysql_root_username'],
    dbpass:   database_creds[node.chef_environment]['mysql_root_password'],
    dbhost:   node['db_endpoint']
  )
end

ruby_block 'Creating wp-config.php with root creds' do
  install = %W{
    /usr/local/bin/wp
    --path=#{node['chef_wordpress']['wordpress_root']}
    --quiet
    config create
  }.join(' ')

  block do
    shell_out!(install)
  end

  not_if { ::File.exist?("#{node['chef_wordpress']['wordpress_root']}/wp-config.php") }
end

template "#{ENV['HOME']}/wp_db_user.sql" do
  source 'wp_create_db_user.sql.erb'
  sensitive true
  mode 0o700
  variables(
    dbname:   database_creds[node.chef_environment]['db_name'],
    wpadmin:  database_creds[node.chef_environment]['db_user'],
    dbpass:   database_creds[node.chef_environment]['db_password'],
    dbhost:   node['db_endpoint'].split(':')[0],
    ip:       node['ipaddress']
  )
end

bash 'Create user in mysql.mysql table' do
  cwd ENV['HOME']
  code <<-EOH
    mysql <wp_db_user.sql
  EOH
end

ruby_block 'Create wordpress db using root creds' do
  install = %w{
    /usr/local/bin/wp1 --quiet db create
  }.join(' ')

  block do
    shell_out!(install)
  end
  not_if '/usr/local/bin/wp1 db check'
end

template "#{node['chef_wordpress']['wordpress_root']}/wp-config.php" do
  source 'wp-config.php.erb'
  sensitive true
  variables(
    wp_debug:                      node['chef_wordpress']['wp_debug'],
    wp_debug_log:                  node['chef_wordpress']['wp_debug_log'],
    wp_debug_display:              node['chef_wordpress']['wp_debug_display'],
    wp_script_debug:               node['chef_wordpress']['wp_script_debug'],
    wp_auto_update_core:           node['chef_wordpress']['wp_auto_update_core'],
    wp_disallow_file_mods:         node['chef_wordpress']['wp_disallow_file_mods'],
    fqdn:                          node['fqdn'],
    dns_aws_access_key_id:         wordpress_creds[node.chef_environment]['dns_aws_access_key_id'],
    dns_aws_secret_access_key:     wordpress_creds[node.chef_environment]['dns_aws_secret_access_key'],
    db_name:                       database_creds[node.chef_environment]['db_name'],
    db_user:                       database_creds[node.chef_environment]['db_user'],
    db_password:                   database_creds[node.chef_environment]['db_password'],
    db_host:                       node['db_endpoint'].split(':')[0],
    db_port:                       node['db_endpoint'].split(':')[1],
    amazon_cloudfront_domain_nam:  node['cloudfront_domain_name']
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
