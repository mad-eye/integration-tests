#! /bin/sh

#could just include in the tarball as well..
wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb

sudo dpkg -i puppetlabs-release-precise.deb
sudo apt-get update -qqy

sudo apt-get install -y curl
sudo apt-get install -y rsync
sudo apt-get install -y puppet

sudo puppet module install puppetlabs/ntp
sudo puppet module install puppetlabs-apt
sudo puppet module install puppetlabs-mongodb
sudo puppet module install rtyler/jenkins

sudo rsync -ruv puppet/modules /usr/share/puppet

sudo puppet apply -e "class {'appserver': environment => 'custom', custom_madeye_host => 'localhost', custom_madeye_url => 'http://localhost', custom_mongo_host => 'localhost'} include madeye_db"
#TODO start services

mkdir -p /home/ubuntu

sudo rm -r /home/ubuntu/current-deploy || echo ""
sudo ln -s `pwd` /home/ubuntu/current-deploy
sudo start azkaban
sudo start apogee
sudo start bolide
