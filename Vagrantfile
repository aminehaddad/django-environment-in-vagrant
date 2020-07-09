Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  # For OSX/LINUX
  config.vm.network "private_network", ip: "10.10.10.10"

  # For WINDOWS (comment the OSX/LINUX and uncomment this line)
  # For WINDOWS, you can access it using http://127.0.0.1:8080/
  # config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"
  config.vm.synced_folder ".", "/home/vagrant/site"
  config.vm.provision "shell", path: "./_conf/vagrant_setup.sh"

  config.vm.provider "virtualbox" do |v|
    v.memory = 512
  end
end
