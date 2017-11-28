database_creds = data_bag_item('secrets', 'database_creds')
wordpress_creds = data_bag_item('secrets', 'wordpress')

template "#{ENV['PWD']}/env_#{node.chef_environment}.tvars" do
  source 'terraform.tvars.erb'
  sensitive true
  variables(
    aws_access_key_id:         wordpress_creds[node.chef_environment]['dns_aws_access_key_id'],
    aws_secret_access_key:     wordpress_creds[node.chef_environment]['dns_aws_secret_access_key'],
    aws_cloudfront_cname:      "#{node['terraform_hostname'] || node['hostname']}cdn.#{node['terraform_domain'] || node['domain']}".downcase,
    mysql_root_username:       database_creds[node.chef_environment]['mysql_root_username'],
    mysql_root_password:       database_creds[node.chef_environment]['mysql_root_password'],
    mysql_wordpress_username:  database_creds[node.chef_environment]['db_user'],
    mysql_wordpress_password:  database_creds[node.chef_environment]['db_password']
  )
end
