# assumption: you have a server on the cloud 
# that you can login as root without password
# you can pass your public key while
# creating the server

PROVIDER="rackspace or virtualbox"
VAGRANT_SERVER="ip address here or localhost"
PREFIX="your initials?"
INSTANCE_NAME="salt-master maybe?"
GITHUB_USERNAME="username"
GITHUB_EMAIL="e-mail"

# rackspace provider specific
# leave empty if you use virtualbox
RACKSPACE_USER="user that can create servers"
RACKSPACE_KEY="long key"
RACKSPACE_ACCOUNT="account number"
RACKSPACE_REGION="iad maybe?"
RACKSPACE_SSH_PUBLIC_KEY="name of public key for RACKSPACE_USER"
RACKPSACE_USLON="us or lon, us is used for anywhere except lon"
PROVIDER_PREFIX="salt cloud provider/profile prefix"
PROVIDER_IMAGES="ubuntu, centos"

if [ $VAGRANT_SERVER = "localhost" ]
    then

    echo
    echo == Configuring Vagrant Environment
    rm -rf ./${PREFIX}-vagrant
    mkdir ./${PREFIX}-vagrant
    git clone https://github.com/saltstackme/salt-vagrant.git ./${PREFIX}-vagrant

    cat <<CONFIGEOF > "./${PREFIX}-vagrant/config.rb"
# sandbox specific variables
PROVIDER = "${PROVIDER}"
HOME = "~/"
PREFIX = "${PREFIX}"
GITHUB_USERNAME = "${GITHUB_USERNAME}"
GITHUB_EMAIL = "${GITHUB_EMAIL}"
INSTANCE_NAME = "${INSTANCE_NAME}"
RACKSPACE_USER = "${RACKSPACE_USER}"
RACKSPACE_KEY = "${RACKSPACE_KEY}"
RACKSPACE_ACCOUNT = "${RACKSPACE_ACCOUNT}"
RACKSPACE_REGION = "${RACKSPACE_REGION}"
CONFIGEOF

    if [ "$(vagrant box list | grep trusty)" ]
    then
        echo Image trusty exits
    else
        vagrant box add trusty https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box
    fi

    # provisioning salt-master
    echo "\n== Provisioning ${PREFIX}-${INSTANCE_NAME}--"
    cd ./${PREFIX}-vagrant
    vagrant up ${PREFIX}-${INSTANCE_NAME}
    vagrant ssh ${PREFIX}-${INSTANCE_NAME}

else # if not local, so remote

    # get token
    TOKEN=`curl -s https://identity.api.rackspacecloud.com/v2.0/tokens -X 'POST' -d '{"auth":{"RAX-\
KSKEY:apiKeyCredentials":{"username":"'$RACKSPACE_USER'", "apiKey":"'$RACKSPACE_KEY'"}}}' -H "Content-Type: application/json" \
| python -c "import sys,json;print json.loads(sys.stdin.readlines()[0])['access']['token']['id']"`

    cat <<EOFJSON > server_build.json
{
    "server" : {
        "name" : "${PREFIX}-vagrant",
        "imageRef" : "5cc098a5-7286-4b96-b3a2-49f4c4f82537",
        "flavorRef" : "performance1-2",
        "metadata" : {
            "My Server Name" : "Vagrant Temporary Server"
        },
        "key_name": "${RACKSPACE_SSH_PUBLIC_KEY}"
    }
}
EOFJSON

    # create server
    INSTANCE_ID=`curl -s https://${RACKSPACE_REGION}.servers.api.rackspacecloud.com/v2/$RACKSPACE_ACCOUNT/servers \
       -X POST \
       -H "Content-Type: application/json" \
       -H "X-Auth-Token: $TOKEN" \
       -H "X-Auth-Project-Id: test-project" \
       -T server_build.json | python -c "import sys,json;print json.loads(sys.stdin.readlines()[0])['server']['id']"`

    STATUS="INITIATED"

    while [ "$STATUS" != "ACTIVE" ]
    do
        echo "Waiting for instance to boot up, status : $STATUS"
        sleep 5
        STATUS=`curl -s https://${RACKSPACE_REGION}.servers.api.rackspacecloud.com/v2/$RACKSPACE_ACCOUNT/servers/$INSTANCE_ID \
           -H "X-Auth-Token: $TOKEN" | python -c "import sys,json;print json.loads(sys.stdin.readlines()[0])['server']['status']"`
    done

    echo "Server ready"
    sleep 5

    INSTANCE_IP=`curl -s https://${RACKSPACE_REGION}.servers.api.rackspacecloud.com/v2/$RACKSPACE_ACCOUNT/servers/$INSTANCE_ID \
           -H "X-Auth-Token: $TOKEN" | python -c "import sys,json;print json.loads(sys.stdin.readlines()[0])['server']['accessIPv4']"`

    VAGRANT_SERVER=$INSTANCE_IP
    echo "VAGRANT_SERVER IP ADDRESS: $VAGRANT_SERVER"
   
    sed -i -e  "/${VAGRANT_SERVER}/d" ~/.ssh/known_hosts
    #ssh -o "StrictHostKeyChecking no" root@${VAGRANT_SERVER} exit

    echo "\n== Copying SSH keys\n---------------"
    scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa* root@${VAGRANT_SERVER}:/root/.ssh/

    echo "\n== Installing Vagrant\n-------------"
    ssh -o "StrictHostKeyChecking no" root@${VAGRANT_SERVER} <<EOF
echo
echo == Installing Vagrant
apt-get update
apt-get install ruby-dev build-essential automake libtool emacs24-nox git screen -y
apt-get install vagrant -y

echo
echo == Installing rackspace plugin, this may take a while
vagrant plugin install vagrant-rackspace

echo
echo == Configuring Vagrant Environment
rm -rf /root/vagrant
mkdir /root/vagrant
git clone https://github.com/saltstackme/salt-vagrant.git /root/vagrant

cat <<CONFIGEOF > "/root/vagrant/config.rb"
# sandbox specific variables
PROVIDER = "${PROVIDER}"
HOME = "/root"
PREFIX = "${PREFIX}"
GITHUB_USERNAME = "${GITHUB_USERNAME}"
GITHUB_EMAIL = "${GITHUB_EMAIL}"
INSTANCE_NAME = "${INSTANCE_NAME}"
RACKSPACE_USER = "${RACKSPACE_USER}"
RACKSPACE_KEY = "${RACKSPACE_KEY}"
RACKSPACE_ACCOUNT = "${RACKSPACE_ACCOUNT}"
RACKSPACE_REGION = "${RACKSPACE_REGION}"
RACKPSACE_USLON = "${RACKPSACE_USLON}"
PROVIDER_PREFIX = "${PROVIDER_PREFIX}"
PROVIDER_IMAGES = "${PROVIDER_IMAGES}"
CONFIGEOF

cd /root/vagrant
vagrant box add dummy https://github.com/mitchellh/vagrant-rackspace/raw/master/dummy.box

echo
echo == Logging into Vagrant Server: $VAGRANT_SERVER
echo
EOF

    # provisioning salt-master
    echo "\n== Provisioning ${PREFIX}-${INSTANCE_NAME}--"
    ssh -o "StrictHostKeyChecking no" root@${VAGRANT_SERVER} <<MASTEREOF
cd /root/vagrant
vagrant up ${PREFIX}-${INSTANCE_NAME} --provider=rackspace
vagrant ssh ${PREFIX}-${INSTANCE_NAME}
/etc/init.d/salt-master stop
/etc/init.d/salt-minion stop
/etc/init.d/salt-master start
/etc/init.d/salt-minion start
sleep 10
echo =============================================================
echo Login to ${PREFIX}-${INSTANCE_NAME} with the IP address below
salt-call network.ipaddrs eth0 | python -c "import sys,yaml;print yaml.load(sys.stdin.readlines()[1])[0]"
echo =============================================================
exit
MASTEREOF

echo == Deleting Vagrant Server
DELETE_VAGRANT=`curl -s https://${RACKSPACE_REGION}.servers.api.rackspacecloud.com/v2/$RACKSPACE_ACCOUNT/servers/$INSTANCE_ID \
       -X DELETE \
       -H "X-Auth-Token: $TOKEN"`
echo == Done
fi