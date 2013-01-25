#! /bin/sh
#Usage: configServer.sh SERVER_PUBLIC_DNS
set -e

PUBLIC_DNS=$1

packages="emacs23-nox"
cmd="ssh -i $HOME/.ssh/horcrux.pem ubuntu@$PUBLIC_DNS "

#initial setup
$cmd "sudo apt-get -y install $packages"
$cmd "sudo apt-get -y update"
$cmd "sudo mkdir -p /etc/apt/sources.list.d"

#Installing Node
$cmd "sudo apt-get -y install python-software-properties"
$cmd "sudo add-apt-repository -y ppa:chris-lea/node.js" # Up-to-date node repo
$cmd "sudo apt-get -y update"
$cmd "sudo apt-get -y install nodejs npm"

#Installing Mongo

$cmd "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
# the 10gen repository.
$cmd "echo \"deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen\" | sudo tee /etc/apt/sources.list.d/10gen.list"
$cmd "sudo apt-get -y update"
$cmd "sudo apt-get -y install mongodb-10gen"

#Installing Redis
$cmd "echo \"deb http://packages.dotdeb.org squeeze all\" | sudo tee /etc/apt/sources.list.d/dotdeb.org.list"
$cmd "echo \"deb-src http://packages.dotdeb.org squeeze all\" | sudo tee -a /etc/apt/sources.list.d/dotdeb.org.list"
$cmd "wget -q -O - http://www.dotdeb.org/dotdeb.gpg | sudo apt-key add -"
$cmd "sudo apt-get -y update"
$cmd "sudo apt-get -y install redis-server"

#Npm packages
$cmd "sudo npm install -g coffee-script"
$cmd "sudo apt-get -y install zip"

