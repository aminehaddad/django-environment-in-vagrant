Vagrant.configure("2") do |config|
  config.vm.box = "trusty-server-cloudimg-i386-vagrant-disk1"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box"
  
  # For OSX/LINUX
  config.vm.network "private_network", ip: "10.10.10.10"

  # For WINDOWS (comment the OSX/LINUX and uncomment this line)
  # For WINDOWS, you can access it using http://127.0.0.1:8080/
  # config.vm.network "forwarded_port", guest: 8080, host: 8080

  config.vm.synced_folder ".", "/home/vagrant/site"
  config.vm.provision "shell", path: "./_conf/vagrant_setup.sh"
end
