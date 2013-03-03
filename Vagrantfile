Vagrant::Config.run do |config|
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  config.vm.network :hostonly, "192.168.31.100"

  config.vm.share_folder("site", "/home/vagrant/site", ".", :nfs => true)
  config.vm.provision :shell, :path => "./_conf/vagrant_setup.sh"
end
