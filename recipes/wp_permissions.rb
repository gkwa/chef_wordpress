bash 'makes themes/plugin upload work' do
  code <<-EOH
    chown -R wp-user:wp-user #{node['chef_wordpress']['wordpress_root']}
    EOH
end

bash 'lock down filesystem permissions' do
  code <<-EOH
    chmod -R u+rwX,go+rX,go-w #{node['chef_wordpress']['wordpress_root']}
    EOH
end
