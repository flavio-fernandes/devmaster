#!/usr/bin/env bash

[ $EUID -eq 0 ] || { echo 'must be root' >&2; exit 1; }

set -o xtrace
##set -o errexit

dnf install -y tmux wget emacs vim tmate bat pip dnsutils cronie
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

cat << EOT >> /home/vagrant/.zshrc
sudo ip route add 10.0.0.0/8 via 10.18.97.254 2>/dev/null ||:
#sudo ip route add 192.168.2.0/24 via 192.168.30.254 2>/dev/null ||:
EOT
# ip route add 192.168.2.0/24 via 192.168.30.254 2>/dev/null ||:
ip route add 10.0.0.0/8 via 10.18.97.254 2>/dev/null ||:

echo ok
