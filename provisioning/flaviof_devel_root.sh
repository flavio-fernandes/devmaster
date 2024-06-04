#!/usr/bin/env bash

[ $EUID -eq 0 ] || { echo 'must be root' >&2; exit 1; }

set -o xtrace
##set -o errexit

dnf install -y tmux wget emacs-nox vim tmate bat pip dnsutils cronie mosh
dnf groupinstall -y "Development Tools"

cat << EOT >> /root/.emacs
;; use C-x g for goto-line
(global-set-key "\C-xg" 'goto-line)
(setq line-number-mode t)
(setq column-number-mode t)
(setq make-backup-files nil)

;; tabs are evail
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)
(setq-default c-basic-offset 4)
EOT

[ -e /home/vagrant/.emacs ] || {
    cp -v {/root,/home/vagrant}/.emacs
    chown vagrant:vagrant /home/vagrant/.emacs
}

# k9s
mkdir -pv /tmp/k9_install && cd /tmp/k9_install
wget --quiet https://github.com/derailed/k9s/releases/download/v0.26.7/k9s_Linux_x86_64.tar.gz && \
tar xzvf k9s_Linux_x86_64.tar.gz k9s
chmod +x ./k9s
mv -vf ./k9s /usr/local/bin/

cat << EOT >> /home/vagrant/.zshrc
#sudo ip route add 10.0.0.0/8 via 10.18.57.254 2>/dev/null ||:
sudo ip route add 192.168.2.0/24 via 192.168.30.254 2>/dev/null ||:
sudo ip route del default via 192.168.121.1 dev eth0 2>/dev/null ||:
EOT
sudo ip route add 192.168.2.0/24 via 192.168.30.254 2>/dev/null ||:
sudo ip route del default via 192.168.121.1 dev eth0 2>/dev/null ||:
# ip route add 10.0.0.0/8 via 10.18.57.254 ||:

sudo chown -R vagrant:vagrant /home/vagrant/.zshrc.d
## ln -s /home/vagrant/zshrc.d /home/vagrant/.zshrc.d ||:

echo ok
