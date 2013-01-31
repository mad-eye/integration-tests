#! /bin/sh
#Usage: configServer.sh SERVER_PUBLIC_DNS
set -e

#TODO: Take production/staging argument, and push the appropriate /etc/init/APP.conf scripts
PUBLIC_DNS=$1

packages="emacs23-nox git htop"
cmd="ssh -i $HOME/.ssh/horcrux.pem ubuntu@$PUBLIC_DNS "
rsync=rsync\ -uv\ -e\ "ssh -i $HOME/.ssh/horcrux.pem"
#initial setup
$cmd "sudo apt-get -y install $packages"
$cmd "sudo apt-get -y update"
$cmd "mkdir tmp" #HACK: Make this dir with correct permissions before someone else does.
$cmd "sudo mkdir -p /etc/apt/sources.list.d"

#Installing Node
$cmd "sudo apt-get -y install python-software-properties"
$cmd "sudo add-apt-repository -y ppa:chris-lea/node.js" # Up-to-date node repo
$cmd "sudo apt-get -y update"
$cmd "sudo apt-get -y install nodejs npm"

#Npm packages
$cmd "sudo npm install -g coffee-script meteorite"
$cmd "sudo apt-get -y install zip"

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

#install etc/init scripts
#TODO: This will change based on production/staging
$rsync etcinit/production/*.conf ubuntu@$PUBLIC_DNS:/tmp
$cmd "sudo mv /tmp/apogee.conf /tmp/azkaban.conf /tmp/bolide.conf /etc/init/"

#install nginx
#TODO: This will change based on production/staging
$cmd "sudo apt-get -y install nginx"
$rsync nginx/production ubuntu@$PUBLIC_DNS:/tmp
$cmd "sudo mv /tmp/production /etc/nginx/sites-available/"
$cmd "sudo rm /etc/nginx/sites-enabled/production || echo \"No production symlink\"" 
$cmd "sudo ln -s /etc/nginx/sites-available/production /etc/nginx/sites-enabled/production"
$cmd "sudo rm /etc/nginx/sites-enabled/default || echo \"No default site\""
$cmd "sudo rm /etc/nginx/sites-available/default || echo \"No default site\""
$cmd "sudo /etc/init.d/nginx start"

#TODO: Make nginx startup automatically
#TODO: Still might need to a do a git clone on the machine to accept github's rsa key.
#XXX: mrt was failing after this setup, we had to do "rm -rf /home/ubuntu/.meteorite" to fix it
