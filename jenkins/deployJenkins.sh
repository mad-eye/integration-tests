#! /bin/bash

rsync -rcv jenkins_templates/ jenkins@ci.madeye.io:jobs/
