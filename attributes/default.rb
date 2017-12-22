default['nginx']['group']                                                 = 'www-data'
default['nginx']['user']                                                  = 'www-data'
default['nginx']['worker_connections']                                    = 8000
default['nginx']['worker_rlimit_nofile']                                  = 10_000
cc                                                                        = Mixlib::ShellOut.new('cat /proc/cpuinfo | grep processor | wc -l')
cores                                                                     = cc.run_command.stdout.to_i # runs it, gets stdout, converts to integer
default['nginx']['worker_processes']                                      = 2 * cores
default['nginx']['default_root']                                          = '/usr/share/nginx/html'
default['chef_wordpress']['wordpress_root']                               = '/usr/share/nginx/html/wordpress'
default['chef_wordpress']['fpm_socket_test']                              = '/var/run/php/test-fpm.sock'
default['chef_wordpress']['fpm_socket_wordpress']                         = '/var/run/php/wordpress-fpm.sock'
default['php']['fpm_socket_type']                                         = 'unix'
default['php']['directives']                                              = { 'upload_max_filesize' => '201M',
                                                                              'post_max_size' => '201M' }
default['php']['gd']['package']                                           = 'php56-gd' if platform_family?('amazon')
default['nginx']['client_max_body_size']                                  = node['php']['directives']['post_max_size']

default['certbot']['sandbox']['webroot_path']                             = node['nginx']['default_root']

default['chef_wordpress']['config_backup_repo_path']                      = '/usr/local/src/backup.git'

default['chef_wordpress']['wordpress_url']                                = "https://#{node['fqdn']}/"
default['chef_wordpress']['wordpress_title']                              = 'Streambox'
default['prometheus-platform']['components']['node_exporter']['install?'] = true

default['chef_wordpress']['wp_debug']                                     = 'false'
default['chef_wordpress']['wp_debug_log']                                 = 'false'
default['chef_wordpress']['wp_debug_display']                             = 'false'
default['chef_wordpress']['wp_script_debug']                              = 'false'
default['chef_wordpress']['wp_auto_update_core']                          = 'false'
default['chef_wordpress']['wp_disallow_file_mods']                        = 'true'

default['chef_wordpress']['backup_s3_bucket']                             = "#{node['fqdn']}-backup"
default['chef_wordpress']['cloudfront_s3_bucket']                         = node['fqdn']

# install mysql client
default['mysql']['version'] = value_for_platform(
  'ubuntu' => { '>= 16.04' => '5.7' },
  'default' => '5.6'
)

case node['platform_family']
when 'rhel', 'debian'
  default['chef_wordpress']['fpm_socket_test']                            = '/var/run/test-fpm.sock'
  default['chef_wordpress']['fpm_socket_wordpress']                       = '/var/run/wordpress-fpm.sock'
when 'fedora', 'amazon'
  default['php']['fpm_socket_type']                                       = 'tcp'
  default['chef_wordpress']['fpm_socket_test']                            = '127.0.0.1:9000'
  default['chef_wordpress']['fpm_socket_wordpress']                       = '127.0.0.1:9001'
  default['php']['mysql']['package']                                      = 'php56-mysqlnd'
end

# W3 Total Cache with New Relic Monitoring
default['chef_wordpress']['wp_w3tc_newrelic_application_name'] = 'PHP Application'

default['chef_wordpress']['plugins'] = %w(
  404page
  adroll-retargeting
  akismet
  amazon-web-services
  amazon-s3-and-cloudfront
  better-search-replace
  better-font-awesome
  contact-form-7
  contact-form-7-to-database-extension
  duplicate-post
  embed-google-adwords-codes-on-woocommerce
  fix-admin-contrast
  google-pagespeed-insights
  image-caption-hover
  master-slider
  pixelyoursite
  pretty-link
  redirection
  ricg-responsive-images
  simple-full-screen-background-image
  simple-image-sizes
  simple-signup-form
  snapshot
  swerve
  tabby-responsive-tabs
  table-maker
  tablepress
  vc-mega-footer
  vertical-scroll-recent-post
  video-background-pro
  w3-total-cache
  wordpress-importer
  wordpress-seo
  wp-facebook-pixel
  wp-force-ssl
  wp-gmail-smtp
  wp-hummingbird
  wp-link-status
  wp-live-chat-software-for-wordpress
  wp-newrelic
  wp-optimize
  wp-smush-pro
  wpmu-dev-seo
  wpmudev-updates
)
