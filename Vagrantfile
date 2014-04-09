Vagrant::Config.run do |config|
  config.vm.box = "raring-server-cloudimg-i386-vagrant-disk1"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-i386-vagrant-disk1.box"
  config.vm.network :hostonly, "10.10.10.10"

  config.vm.share_folder("site", "/home/vagrant/site", ".", :nfs => false)
  config.vm.provision :shell, :path => "./_conf/vagrant_setup.sh"
end
