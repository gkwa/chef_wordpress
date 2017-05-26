VAGRANTFILE_API_VERSION = '2'.freeze

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Don't keep reinstalling virtualbox guest additions, it takes too
  # much time
  config.vbguest.auto_update = false if Vagrant.has_plugin?('vagrant-vbguest')

  # Cache the chef client omnibus installer to speed up testing
  config.omnibus.cache_packages = true if Vagrant.has_plugin?('vagrant-omnibus')
end
