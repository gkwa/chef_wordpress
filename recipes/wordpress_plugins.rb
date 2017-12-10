ruby_block 'Install Wordpress plugins' do
  list = 'wp1 plugin list --field=name'

  block do
    installed = shell_out(list).stdout.split(/[\s\n]+/)
    Chef::Log.info("plugins already installed: #{installed}")
    proposed = node['chef_wordpress']['plugins']
    todo_list = proposed - installed
    unless todo_list.empty?
      todo = todo_list.join(' ')
      install = "wp1 plugin install --activate #{todo}"
      Chef::Log.info("install cmd: #{install}")
      shell_out(install)
    end
  end
end

bash 'Download Wordpress purchased assets' do
  code <<-EOH
    /usr/local/bin/aws s3 sync --exclude '*' --include '*.zip' s3://www.streambox.com-wordpress-purchased-assets /tmp/purchased

    # 8.5.0:
    wp1 theme install --force --activate /tmp/purchased/theme/purchased/salient-8.5.0/themeforest-4363266-salient-responsive-multipurpose-theme/salient.zip

    # 5.2.2:
    wp1 plugin install --force --activate /tmp/purchased/theme/purchased/salient-8.5.0/themeforest-4363266-salient-responsive-multipurpose-theme/salient/plugins/js_composer_salient.zip
  EOH
end
