# convenience for debugging, add config files to vim history
ruby_block 'Add files to nvim queue for debug' do
  list = %w{
    /etc/postfix/sasl_passwd
    /etc/postfix/master.cf
    /etc/postfix/main.cf
    /etc/postfix/virtual
    ~/.config/nvim
    ~/.vim
    /etc/nginx/nginx.conf
    /etc/letsencrypt/live/
    /etc/nginx/sites-available/
    /etc/nginx/sites-enabled/
    /usr/share/nginx/html/wordpress
    /usr/share/nginx/html/wordpress/wp-config.php
    /usr/share/nginx/html
    /etc/nginx
    /var/run
    /var/www
    /etc/php.ini
    /etc/php
    /etc/php.d
    /etc/php-fpm.d/default.conf
    /etc/php-fpm.d
    /etc/php-fpm.conf
    /var/log/php-fpm
    /var/log
    /var/log/nginx/wordpress.access.log
  }.join(' ')

  cmd = "vim #{list} +qall"

  block do
    shell_out!(cmd)
  end
end
