# FIXME: find alternative for amazon
unless platform_family?('amazon')
  package %w(optipng jpegoptim)

  template '/usr/local/bin/wpimages' do
    source 'wpimages.sh.erb'
    variables(
      config_backup_repo_path: node['chef_wordpress']['wordpress_root']
    )
    mode 0o755
  end

  cron 'wp images optimize' do
    user 'root'
    time :daily
    command %w{
      #nice -n 19 /usr/local/bin/wpimages >>/var/log/wp_optipng.log 2>&1
    }.join(' ')
  end
end
