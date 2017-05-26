include_recipe 'php'

package node['php']['gd']['package']

remote_file '/usr/local/bin/wp-cli.phar' do
  source 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
  mode 0o755
end

directory node['nginx']['default_root'] do
  recursive true
end

template '/usr/local/bin/wp' do
  source 'wp.erb'
  mode 0o755
end

template '/usr/local/bin/wp1' do
  source 'wp1.erb'
  mode 0o755
end

# php-curl already enabled on amazon and
# yum search php-curl yeilds nada
package node['php']['curl']['package'] unless platform_family?('amazon')
# required by CDNs
if platform_family?('debian')
  bash 'enable curl' do
    code <<-EOH
      phpenmod curl
      EOH
    notifies :reload, 'service[nginx]', :delayed
    notifies :restart, "service[#{node['php']['fpm_service']}]", :delayed
    not_if 'php -m | grp curl'
  end
else
  Chef::Log.warn('FIXME: we need to enable curl for non-debian')
end

service node['php']['fpm_service'] do
  action :nothing
end

directory node['chef_wordpress']['wordpress_root'] do
  recursive true
end
template "#{node['chef_wordpress']['wordpress_root']}/phpinfo.php" do
  source 'phpinfo.php.erb'
end

group 'wp-user' do
  action :create
  append true
end

user 'wp-user' do
  manage_home true
  home '/home/wp-user'
  group 'wp-user'
  action :create
end

php_fpm_pool 'wordpress' do
  listen node['chef_wordpress']['fpm_socket_wordpress']
  user 'wp-user'
  group 'wp-user'
  action :install
end

# FIXME: PHP chef cookbook doesn't set these properly and this is what allows
# theme and plugin upload without getting error.

# We should set these values manually for now

# /etc/php/7.0/fpm/php.ini:post_max_size = 201M
# /etc/php/7.0/fpm/php.ini:upload_max_filesize = 201M

wordpress_creds = data_bag_item('secrets', 'wordpress')

package value_for_platform_family(
  %w(debian suse) => 'apache2-utils',
  'amazon' => 'httpd24-tools',
  'default' => 'httpd-tools'
)

directory '/etc/apache2' do
  action :create
end

bash 'Generate nginx basic auth password file' do
  code <<-EOH
    htpasswd -b -c /etc/apache2/.htpasswd "#{wordpress_creds[node.chef_environment]['wordpress_generic_admin_user']}" "#{wordpress_creds[node.chef_environment]['wordpress_generic_admin_password']}"
    EOH
end
