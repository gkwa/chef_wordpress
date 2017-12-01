template '/usr/local/bin/wpbootstrap' do
  source 'wpbootstrap.erb'
  mode 0o700
end

template '/tmp/debug_db_create.sql' do
  source 'debug_db_create.sql.erb'
  mode 0o700
end
