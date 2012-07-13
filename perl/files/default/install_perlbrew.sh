#!/bin/bash
export PERLBREW_ROOT=/usr/local/perlbrew
curl -kL http://install.perlbrew.pl | bash
echo "source ${PERLBREW_ROOT}/etc/bashrc" >> /root/.bashrc &&
. /root/.bashrc &&
perlbrew init
