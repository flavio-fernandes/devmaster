# devmaster
## Fedora users
Installing the basic:
```
$ sudo dnf install @vagrant
```

Installing the recommended vagrant plugins:
```
$ vagrant plugin install vagrant-hostmanager vagrant-libvirt vagrant-sshfs vagrant-ssh
```

To verify all plugins are installed:
```
$ vagrant plugin list
vagrant-hostmanager (1.8.9, global)
vagrant-libvirt (0.4.1, system)
vagrant-ssh (2.1.0, global)
vagrant-sshfs (1.3.6, global)
```

## Using bridge mode
Flavio's fork adds the `bridge mode` support. 

On **Linux machines** the `default bridge name` is `virbr0` but users are free to change. Assuming users will use `virbr0` please change the following:

```
--- a/Vagrantfile
+++ b/Vagrantfile
@@ -24,7 +24,7 @@ Vagrant.configure("2") do |config|
         "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
   end
   config.vm.network "public_network",
-                    :dev => "bridge0",
+                    :dev => "virbr0",
                     :mode => "bridge",
                     :type => "bridge"
```

On top of that, make sure to set the proper permission to the user that will run the `vagrant up`
```
echo "allow all" | sudo tee /etc/qemu/${USER}.conf
echo "include /etc/qemu/${USER}.conf" | sudo tee --append /etc/qemu/bridge.conf
sudo chown root:${USER} /etc/qemu/${USER}.conf
sudo chmod 640 /etc/qemu/${USER}.conf
```

After that `vagrant up` should work out of box.

```
$ git clone https://github.com/flavio-fernandes/devmaster && cd devmaster
$ vagrant up
```

