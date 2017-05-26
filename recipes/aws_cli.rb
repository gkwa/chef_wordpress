wordpress_creds = data_bag_item('secrets', 'wordpress')

directory "#{ENV['HOME']}/.aws" do
  mode 0o700
end

template "#{ENV['HOME']}/.aws/credentials" do
  source 'credentials_aws.erb'
  variables(
    dns_aws_access_key_id: wordpress_creds[node.chef_environment]['dns_aws_access_key_id'],
    dns_aws_secret_access_key: wordpress_creds[node.chef_environment]['dns_aws_secret_access_key']
  )
  mode 0o700
  sensitive true
end

if ::File.exist?('/usr/bin/aws')
  link '/usr/local/bin/aws' do
    to '/usr/bin/aws'
  end
end
