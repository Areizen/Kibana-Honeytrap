Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "private_network", ip: "192.168.50.50"
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 2
  config.vm.provision "shell", 
  path: "provision.sh"
  end
end