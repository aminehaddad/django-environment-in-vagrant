Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"

  if Vagrant::Util::Platform.windows?
    config.vm.network "private_network", ip: "10.10.10.10"
  elsif Vagrant::Util::Platform.darwin?
    config.vm.network "private_network", ip: "10.10.10.10"
  else
    config.vm.network "private_network", ip: "10.10.10.10"
  end

  config.vm.synced_folder ".", "/home/vagrant/site"
  config.vm.provision "shell", path: "./_conf/vagrant_setup.sh"

  config.vm.provider "virtualbox" do |v|
    v.memory = 512
  end

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false  
  end
end
