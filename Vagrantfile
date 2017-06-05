Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu-16.04-server-cloudimg-i386-vagrant"
  config.vm.box_url = "https://cloud-images.ubuntu.com/releases/server/16.04/release/ubuntu-16.04-server-cloudimg-i386-vagrant.box"

  # For OSX/LINUX
  config.vm.network "private_network", ip: "10.10.10.10"

  # For WINDOWS (comment the OSX/LINUX and uncomment this line)
  # For WINDOWS, you can access it using http://127.0.0.1:8080/
  # config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"
  config.vm.synced_folder ".", "/home/ubuntu/site"
  config.vm.provision "shell", path: "./_conf/vagrant_setup.sh"
end
