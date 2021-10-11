Vagrant.configure("2") do |config|  
  # Changed to ubuntu/focal64 due to bento/ubuntu-20.04 failures (not updated?)
  # config.vm.box = "bento/ubuntu-20.04"
  config.vm.box = "ubuntu/focal64"

  if Vagrant::Util::Platform.windows?
    # Changed to public network for Windows since it fails or has slow connections.
    # config.vm.network "private_network", ip: "10.10.10.10"
    config.vm.network "public_network", ip: "10.10.10.10"
  elsif Vagrant::Util::Platform.darwin?
    config.vm.network "private_network", ip: "10.10.10.10"
  else
    config.vm.network "private_network", ip: "10.10.10.10"
  end

  config.vm.synced_folder ".", "/home/vagrant/site"
  config.vm.provision "shell", path: "./_conf/vagrant_setup.sh"

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 4
  end

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false  
  end
end
