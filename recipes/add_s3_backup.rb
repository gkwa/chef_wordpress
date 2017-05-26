template '/usr/local/bin/backupwps3_functions.sh' do
  source 'backupwps3_functions.sh.erb'
  mode 0o755
end

template '/usr/local/bin/backupwps3' do
  source 'backupwps3.sh.erb'
  mode 0o755
end

cron 's3 backup' do
  user 'root'
  time :daily
  command %w{
    /usr/local/bin/backupwps3
  }.join(' ')
end
