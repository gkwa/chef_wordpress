database_creds = data_bag_item('secrets', 'database_creds')
wordpress_creds = data_bag_item('secrets', 'wordpress')

template "#{ENV['PWD']}/env_#{node.chef_environment}.tvars" do
  source 'terraform.tvars.erb'
  sensitive true
  variables(
    aws_access_key_id:             wordpress_creds[node.chef_environment]['dns_aws_access_key_id'],
    aws_secret_access_key:         wordpress_creds[node.chef_environment]['dns_aws_secret_access_key'],
    aws_cloudfront_cname:          node['chef_wordpress']['aws_cloudfront_cname'],
    mysql_root_username:           database_creds[node.chef_environment]['mysql_root_username'],
    mysql_root_password:           database_creds[node.chef_environment]['mysql_root_password'],
    mysql_wordpress_password:      wordpress_creds[node.chef_environment]['wordpress_generic_admin_user'],
    mysql_wordpress_username:      wordpress_creds[node.chef_environment]['wordpress_generic_admin_password'],
    chef_provisioner_user_key:     node['chef_wordpress']['chef_provisioner_user_key'],
    chef_provider_client_name:     node['chef_wordpress']['chef_provider_client_name'],
    s3_backup_bucket:              "#{node['chef_wordpress']['fqdn']}-backup",
    node_name:                     node['chef_wordpress']['node_name']
  )
end
