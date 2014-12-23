Vagrant.configure("2") do |config|

  config.puppet_install.puppet_version = :latest

  # Enable the Puppet provisioner, with will look in manifests
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "default.pp"
    puppet.module_path = "modules"
    puppet.hiera_config_path = "hiera.yaml"
    puppet.working_directory = "/vagrant/hieradata"
  end

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "deb76"

  # Forward guest port 80 to host port 8888 and name mapping
  config.vm.network :forwarded_port, guest: 80, host: 8888

  config.vm.synced_folder "webroot/", "/vagrant/webroot/", :owner => "www-data"
end
