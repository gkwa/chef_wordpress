group node['nginx']['group'] do
  action :create
  append true
end

user node['nginx']['user'] do
  group node['nginx']['group']
  action :create
end

include_recipe 'chef_nginx::default'

nginx_site 'default' do
  enable false # legacy "action"
end
