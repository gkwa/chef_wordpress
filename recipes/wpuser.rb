template '/tmp/wpuser' do
  source 'wpuser.erb'
  mode 0o700
end

service node['php']['fpm_service'] do
  action :nothing
end

execute 'configure wordpress/nginx to enable uploads' do
  command '/tmp/wpuser'
  notifies :reload, 'service[nginx]', :delayed
  notifies :restart, "service[#{node['php']['fpm_service']}]", :delayed
  not_if { ::File.exist?('/home/wp-user/wp_rsa') }
end
