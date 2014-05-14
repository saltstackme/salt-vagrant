# assumption: you have a server on the cloud 
# that you can login as root without password
# you can pass your publix key while
# creating the server

VAGRANT_SERVER="ip address here"
HOME="home folder where id_rsa and id_rsa.pub is"
PREFIX="your initials?"
INSTANCE_NAME="salt-mastet maybe?"
GITHUB_USERNAME="username"
GITHUB_EMAIL="e-mail"
RACKSPACE_USER="user that can create servers"
RACKSPACE_KEY="long key"
RACKSPACE_REGION="iad maybe?"

echo "VAGRANT_SERVER IP ADDRESS: $VAGRANT_SERVER"

echo "Fisrt SSH access"
ssh root@${VAGRANT_SERVER} exit

echo "\nCopying SSH keys\n---------------"
scp ${HOME}/.ssh/id_rsa* root@${VAGRANT_SERVER}:/root/.ssh/

echo "\nInstalling Vagrant\n-------------"
ssh root@${VAGRANT_SERVER} <<EOF
echo
echo == Updating repo
apt-get update

echo
echo == Installing required libraries
apt-get install ruby-dev build-essential automake libtool emacs24-nox git screen -y

echo
echo == Installing Vagrant
apt-get install vagrant -y

echo
echo == Installing rackspace plugin, this may take a while
vagrant plugin install vagrant-rackspace

echo
echo == Installation Complete

echo
echo == Configuring Vagrant Environment
rm -rf /root/vagrant
mkdir /root/vagrant
git clone https://github.com/ozgurakan/salt-vagrant.git /root/vagrant

cat <<CONFIGEOF > "/root/vagrant/config.rb"
# sandbox specific variables
HOME = "${HOME}"
PREFIX = "${PREFIX}"
GITHUB_USERNAME = "${GITHUB_USERNAME}"
GITHUB_EMAIL = "${GITHUB_EMAIL}"
INSTANCE_NAME = "${INSTANCE_NAME}"
RACKSPACE_USER = "${RACKSPACE_USER}"
RACKSPACE_KEY = "${RACKSPACE_KEY}"
RACKSPACE_REGION = "${RACKSPACE_REGION}"
CONFIGEOF

cd /root/vagrant
vagrant box add dummy https://github.com/mitchellh/vagrant-rackspace/raw/master/dummy.box

echo
echo == Logging into VAgrant Server: $VAGRANT_SERVER
echo
EOF

ssh root@${VAGRANT_SERVER}


