database_creds = data_bag_item('secrets', 'database_creds')

mysql_client_installation_package 'default' do
  version node['mysql']['version']
  action :create
end

template "#{ENV['HOME']}/.my.cnf" do
  source 'my.cnf.erb'
  variables(
    db_host:      database_creds[node.chef_environment]['db_host'],
    db_user:      database_creds[node.chef_environment]['db_user'],
    db_port:      database_creds[node.chef_environment]['db_port'],
    db_password:  database_creds[node.chef_environment]['db_password']
  )
  mode 0o600
  sensitive true
end
