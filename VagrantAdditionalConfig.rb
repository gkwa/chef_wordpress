VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Cache apt, rpm, gems, ... as much as I can to speed up testing
  if Vagrant.has_plugin?('vagrant-cachier')
    #    config.cache.auto_detect = true # prefer to be explicit
    config.cache.scope = :box
    config.cache.enable :pacman
    config.cache.enable :rvm
    config.cache.enable :chef
    config.cache.enable :yum
    config.cache.enable :apt
    config.cache.enable :gem
  end

  # Don't keep reinstalling virtualbox guest additions, it takes too
  # much time
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = false
  end

  # Cache the chef client omnibus installer to speed up testing
  if Vagrant.has_plugin?("vagrant-omnibus")
    config.omnibus.cache_packages = true
    config.omnibus.chef_version = '12.10.24'
  end
end
