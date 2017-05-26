include_recipe 'certbot::default'

wordpress_creds = data_bag_item('secrets', 'wordpress')

ruby_block 'certbot init' do
  block do
    shell_out('certbot-auto --non-interactive --os-packages-only')
  end
end

remote_file '/usr/local/bin/certbot-route53.sh' do
  source 'https://raw.githubusercontent.com/jed/certbot-route53/master/certbot-route53.sh'
  mode 0o755
  action :create
end

ruby_block 'answer certbot dns-01 challenge' do
  certbot = 'certbot-auto certonly'

  switches = %W(
    --staging
    --keep-until-expiring
    --text
    --manual-auth-hook /usr/local/bin/certbot-route53.sh
    --manual-public-ip-logging-ok
    --preferred-challenges dns
    --manual
    --eff-email
    --agree-tos
    -m "#{wordpress_creds[node.chef_environment]['wordpress_admin_email']}"
    -d #{node['fqdn']}
  )
  switches.push('--no-bootstrap') if platform_family?('amazon')
  cmd = "#{certbot} #{switches.join(' ')}"
  Chef::Log.info("Certbot renew command: #{cmd}")

  block do
    shell_out(cmd)
  end
end

template '/usr/local/bin/certbotlive' do
  source 'certbotlive.sh.erb'
  variables(
    email: wordpress_creds[node.chef_environment]['wordpress_admin_email'],
    webroot: node['chef_wordpress']['wordpress_root']
  )
  mode 0o755
end
