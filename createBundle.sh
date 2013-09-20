#! /bin/sh
set -e

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

