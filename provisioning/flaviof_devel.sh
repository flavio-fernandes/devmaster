#!/usr/bin/env bash

[ $EUID -eq 0 ] && { echo 'must not be root' >&2; exit 1; }

set -o xtrace
##set -o errexit

for k in flavio-fernandes otherwiseguy cubeek umago numansiddique dceara jcaamano alexanderConstantinescu abhat astoycos dave-tucker bpickard22 kyrtapz ; do
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

echo ok
