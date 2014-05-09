echo 'changing ownership of /srv'
sudo chown vagrant:vagrant /srv

echo 'installing git'
sudo apt-get install git -y

echo 'cloning salt-sandbox from github'
git clone git@github.com:rackerlabs/salt-sandbox.git /srv/salt-sandbox

echo 'configuring git'
git config --global user.name "username"
git config --global user.email "email address"
