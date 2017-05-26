# https://serverfault.com/a/746467/211400
# path of least resistance to disabling fail2ban email notifications

template '/tmp/fail2ban_disable_notifications.sh' do
  source 'fail2ban_disable_notifications.sh.erb'
  mode 0o755
end

execute 'disable fail2ban email notifications' do
  command '/tmp/fail2ban_disable_notifications.sh'
end
