# -*- mode: ruby -*-
# vi: set ft=ruby :

NUM_DEVWORKERS = (ENV['DEVWORKERS'] || 0).to_i
#RAM = 16384
#VCPUS = 4
RAM = 49152
VCPUS = 24

$tweak_routes = <<SCRIPT
nmcli con modify 'Wired connection 2' ipv4.route-metric 50
nmcli con up 'Wired connection 2'

nmcli connection modify 'Wired connection 1' ipv4.never-default yes
nmcli con modify 'Wired connection 1' ipv4.route-metric 200
nmcli con up 'Wired connection 1'
SCRIPT

Vagrant.configure("2") do |config|
  vm_memory = ENV['VM_MEMORY'] || RAM
  vm_cpus = ENV['VM_CPUS'] || VCPUS

  config.vm.box = "fedora/41-cloud-base"
  config.vm.box_url = "https://download.fedoraproject.org/pub/fedora/linux/releases/41/Cloud/x86_64/images/Fedora-Cloud-Base-Vagrant-libvirt-41-1.4.x86_64.vagrant.libvirt.box"
  config.vm.provider "libvirt" do |provider|
    provider.cpus = vm_cpus
    provider.memory = vm_memory
    provider.nested = true
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
                    :type => "bridge",
                    use_dhcp_assigned_default_route: true

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.ssh.forward_agent = true
  config.vm.define "devmaster-ffernandes" do |node|
    node.vm.hostname = "devmaster"

    # for remote development
    node.vm.network "forwarded_port", guest: 22, host: 22222
    
    # as of fedora 40, the disk is 5GB and not expanded so we have to do it ourselves
    node.vm.provider "libvirt" do |libvirt|
      libvirt.machine_virtual_size = 190
    end
    node.vm.provision "growpart", type: "shell", inline: "growpart /dev/vda 4 && btrfs filesystem resize max /"

    # mounts
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

      # node.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_udp: false
      # node.vm.synced_folder "~/dev", "/home/vagrant/dev", type: "nfs", nfs_udp: false
      # node.vm.synced_folder "~/Downloads", "/home/vagrant/Downloads", type: "nfs", nfs_udp: false
      # node.vm.synced_folder "~/.secrets", "/home/vagrant/.secrets", type: "nfs", nfs_udp: false
      
      # use virtiofs for libvirt
      node.vm.provider "libvirt" do |libvirt, override|
        libvirt.memorybacking :access, :mode => "shared"
        libvirt.memorybacking :source, :type => 'memfd'
        # be aware of id mapping if you intend to write to these folders
        # https://libvirt.org/kbase/virtiofs.html#running-unprivileged
        # be also aware of git config safe.directory
        override.vm.synced_folder ".", "/vagrant", type: "virtiofs"
        override.vm.synced_folder "~/dev", "/home/vagrant/dev", type: "virtiofs"
        override.vm.synced_folder "~/Downloads", "/home/vagrant/Downloads", type: "virtiofs"
        override.vm.synced_folder "~/.secrets", "/home/vagrant/.secrets", type: "virtiofs"
      end
      
    else
      node.vm.synced_folder ".", "/vagrant", type: "sshfs"
      node.vm.synced_folder "~/dev", "/home/vagrant/dev", type: "sshfs"
      node.vm.synced_folder "~/Downloads", "/home/vagrant/Downloads", type: "sshfs"
      node.vm.synced_folder "~/.secrets", "/home/vagrant/.secrets", type: "sshfs"
    end

    # have to handle mounts on reboot, vagrant doesn't do it for us
    $fstab=<<~SCRIPT
    save=/var/local/devmaster.fstab.keep
    [ -f "$save" ] && grep -vxF -F "$save" /etc/fstab > /etc/fstab && rm -f "$save"
    while read l; do echo "$l 0 0"; done <<< $(findmnt -rnt virtiofs,nfs -o SOURCE,TARGET,FSTYPE,OPTIONS) > "$save" || rm "$save"
    cat "$save" >> /etc/fstab
    SCRIPT
    node.vm.provision "fstab", type: "shell", run: "always", inline: $fstab

    #provision
    node.vm.provision "system", type: "shell", inline: "/vagrant/.provisioners/provision.sh system", reboot: true
    node.vm.provision "user", type: "shell", inline: "/vagrant/.provisioners/provision.sh user", privileged: false
    node.trigger.before :destroy do |t|
      t.info = "Checking for no dirty dotfiles"
      t.run_remote = {inline: "bash -c 'cd /home/vagrant/.dotfiles && git diff --quiet && git diff --cached --quiet || exit 1'"}
      t.on_error = :halt
    end

    node.vm.provision "tweak_routes", type: "shell",
                      inline: $tweak_routes

    node.vm.provision :shell do |shell|
        shell.path = 'provisioning/flaviof_devel_root.sh'
    end
    node.vm.provision :shell do |shell|
        shell.privileged = false
        shell.path = 'provisioning/flaviof_devel.sh'
    end
  end

  # dummy workers
  (1..NUM_DEVWORKERS).each do |i|
    config.vm.define "devworker#{i}" do |node|
      node.vm.hostname = "devworker#{i}"
    end
  end
  
end
