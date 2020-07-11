## Install epel repo and then install jq
yum install -y epel-release -y && yum install jq

## Install docker-ce related packages
yum install -y yum-utils device-mapper-persistent-data lvm2

## Enable docker-ce repo and install docker engine.
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce
systemctl enable docker && systemctl start docker

## Install latest docker-compose
LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
curl -L "https://github.com/docker/compose/releases/download/$LATEST_VERSION/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

## Install AWX dependencies
yum install -y python2-pip
pip install ansible
pip install docker-compose