database_creds = data_bag_item('secrets', 'database_creds')

template '/usr/local/bin/wpbootstrap' do
  sensitive true
  source 'wpbootstrap.erb'
  mode 0o700
  variables(
    db_name: database_creds[node.chef_environment]['db_name']
  )
end

template '/tmp/debug_db_create.sql' do
  source 'debug_db_create.sql.erb'
  mode 0o700
end
