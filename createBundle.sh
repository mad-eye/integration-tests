#! /bin/sh

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

git submodule update --init --recursive madeye-ops

sudo rsync -ruv madeye-ops/puppet/modules /usr/share/puppet

sudo puppet apply -e "class {'appserver': environment => 'custom', custom_madeye_host => 'localhost', custom_madeye_url => 'http://localhost', custom_mongo_host => 'localhost'} include madeye_db"

bin/init
mkdir deploy
cd apogee && mrt bundle bundle.tar.gz && cd ../
tar -xf apogee/bundle.tar.gz
cp -r bundle deploy
rm -r bundle
rm apogee/bundle.tar.gz

cp -r azkaban deploy
cp -r bolide deploy
cp -r madeye-ops/puppet deploy
cp setup.sh deploy

#replace constants with a special version w/o secrets
cp madeye-ops/puppet/safe-constants.pp deploy/puppet/modules/constants/manifests/init.pp

#tar up
tar -zcf deploy.tar.gz deploy 

rm -r deploy

