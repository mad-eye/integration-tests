#! /bin/sh
git submodule update --init --recursive
(cd apogee && .bin/init)
(cd azkaban && bin/init)
(cd bolide && bin/init)
(cd dementor && bin/init)
