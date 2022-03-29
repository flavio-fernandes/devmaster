#!/usr/bin/env bash

[ $EUID -eq 0 ] && { echo 'must not be root' >&2; exit 1; }

set -o xtrace
##set -o errexit

[ -e /home/vagrant/.emacs ] || {
    cp -v {/root,/home/vagrant}/.emacs
    chown vagrant:vagrant /home/vagrant/.emacs
}

for k in flavio-fernandes otherwiseguy cubeek umago numansiddique dceara jcaamano alexanderConstantinescu abhat astoycos dave-tucker bpickard22 kyrtapz tssurya trozet squeed ; do
  echo -n "$k "
  wget -O - --quiet https://github.com/${k}.keys >> /home/vagrant/.ssh/authorized_keys 2>/dev/null
done
wget -O - --quiet https://launchpad.net/~numansiddique/+sshkeys >> /home/vagrant/.ssh/authorized_keys 2>/dev/null
echo


ln -s /home/vagrant/zshrc.d /home/vagrant/.zshrc.d ||:

# ref 2021-Sep-09-Thu@14:45:53
pip3 install o-must-gather percol --user

cat << EOT >> /home/vagrant/.zshrc
function gqit () {
   local commit_id=\$(git log --pretty=format:'%H %ad %s (%an)' --no-merges --date=short|percol | cut -d ' ' -f1)
   git show \$commit_id
}

alias podman='docker'
set +C
export KUBECONFIG=\${HOME}/admin.conf
EOT

# # https://github.com/go-delve/delve/blob/master/Documentation/installation/README.md
# go install github.com/go-delve/delve/cmd/dlv@latest

echo ok
