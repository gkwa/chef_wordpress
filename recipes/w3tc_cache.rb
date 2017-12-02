wordpress_creds = data_bag_item('secrets', 'wordpress')

d = node['chef_wordpress']['wordpress_root']

%W{
  #{d}/wp-content/w3tc-config
  #{d}/wp-content/cache
}.each do |path|
  directory path do
    group node['nginx']['group']
    owner node['nginx']['owner']
    mode 0o777
    recursive true
  end
end

template "#{d}/nginx.conf" do
  source 'nginx.conf.erb'
end

template "#{d}/wp-content/advanced-cache.php" do
  source 'w3tc-advanced-cache.php.erb'
end

template "#{d}/wp-content/w3tc-config/master.php" do
  source 'w3tc-config-master.php.erb'
  variables(
    wp_w3tc_newrelic_api_key:           wordpress_creds[node.chef_environment]['wp_w3tc_newrelic_api_key'],
    amazon_cloudfront_cname:            node['cloudfront_cname'],
    amazon_cloudfront_domain_name:      node['cloudfront_domain_name'].split('.')[0],
    wp_w3tc_newrelic_application_name:  node['chef_wordpress']['wp_w3tc_newrelic_application_name'],
    google_pagespeed_api_key:           wordpress_creds[node.chef_environment]['google_pagespeed_api_key'],
    amazon_cloudfront_api_key_id:       wordpress_creds[node.chef_environment]['amazon_cloudfront_api_key_id'],
    amazon_cloudfront_api_key:          wordpress_creds[node.chef_environment]['amazon_cloudfront_api_key']
  )
  sensitive true
end
