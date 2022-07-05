# -*- mode: ruby -*-
# vi: set ft=ruby :

NUM_DEVWORKERS = (ENV['DEVWORKERS'] || 0).to_i
RAM = 16384
VCPUS = 4

Vagrant.configure("2") do |config|
  vm_memory = ENV['VM_MEMORY'] || RAM
  vm_cpus = ENV['VM_CPUS'] || VCPUS

  config.vm.box = "fedora/36-cloud-base"
  config.vm.provider "libvirt" do |provider|
    provider.cpus = vm_cpus
    provider.memory = vm_memory
  end
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = vm_cpus
    vb.memory = vm_memory
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize [
        "guestproperty", "set", :id,
        "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
  end
  config.vm.network "public_network",
                    :dev => "bridge0",
                    :mode => "bridge",
                    :type => "bridge"
  # config.vm.network "forwarded_port", guest: 22, host: 22222
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.ssh.forward_agent = true
  config.vm.define "devmaster-ffernandes" do |node|
    node.vm.hostname = "devmaster"
    if ENV['VM_MOUNT_NFS']
      node.vm.synced_folder "#{ENV['PWD']}", "/vagrant", type: "nfs",
                            nfs_udp: false,
                            :linux__nfs_options => ['rw','no_subtree_check','no_root_squash']
      node.vm.synced_folder "~/dev", "/home/vagrant/dev", type: "nfs",
                            nfs_udp: false,
                            :linux__nfs_options => ['rw','no_subtree_check','no_root_squash']
      node.vm.synced_folder "~/Downloads", "/home/vagrant/Downloads", type: "nfs",
                            nfs_udp: false,
                            :linux__nfs_options => ['rw','no_subtree_check','no_root_squash']
      node.vm.synced_folder "~/.secrets", "/home/vagrant/.secrets", type: "nfs",
                            nfs_udp: false,
                            :linux__nfs_options => ['rw','no_subtree_check','no_root_squash']
    else
      node.vm.synced_folder ".", "/vagrant", type: "sshfs"
      node.vm.synced_folder "~/dev", "/home/vagrant/dev", type: "sshfs"
      node.vm.synced_folder "~/Downloads", "/home/vagrant/Downloads", type: "sshfs"
      node.vm.synced_folder "~/.secrets", "/home/vagrant/.secrets", type: "sshfs"
    end
    node.vm.provision "shell", inline: "/vagrant/.provisioners/provision.sh system"
    node.vm.provision "shell", inline: "/vagrant/.provisioners/provision.sh user", privileged: false
    #node.trigger.before :destroy do |t|
    #  t.info = "Checking for no dirty dotfiles"
    #  t.run_remote = {inline: "bash -c 'cd /home/vagrant/.dotfiles && git diff --quiet && git diff --cached --quiet || exit 1'"}
    #  t.on_error = :halt
    #end
    node.vm.provision :shell do |shell|
        shell.path = 'provisioning/flaviof_devel_root.sh'
    end
    node.vm.provision :shell do |shell|
        shell.privileged = false
        shell.path = 'provisioning/flaviof_devel.sh'
    end
  end
  (1..NUM_DEVWORKERS).each do |i|
    config.vm.define "devworker#{i}" do |node|
      node.vm.hostname = "devworker#{i}"
    end
  end
end
