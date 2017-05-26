package 'git'

template '/.gitignore' do
  source 'root.gitignore.erb'
end

bash "Setup backup dir: #{node['chef_wordpress']['config_backup_repo_path']}" do
  code <<-EOH
    unset GIT_WORK_TREE
    git --bare init #{node['chef_wordpress']['config_backup_repo_path']}
  EOH
  not_if { ::Dir.exist?(node['chef_wordpress']['config_backup_repo_path']) }
end

template '/usr/local/bin/backupwpgit' do
  source 'backupwpgit.sh.erb'
  variables(
    config_backup_repo_path: node['chef_wordpress']['config_backup_repo_path']
  )
  mode 0o755
end

cron 'backup nginx' do
  minute '*/15'
  user 'root'
  command %w{
    /usr/local/bin/backupwpgit
  }.join(' ')
end

execute 'backup config now' do
  command '/usr/local/bin/backupwpgit'
  return [0, 1]
end
