#!/usr/bin/env bash

# Install python3 and pip. Depending on your linux flavour you may need to change this. 
apt-get update
apt-get install -y python3
apt-get install -y libpython3.5
apt-get install -y python3-pip
apt-get -f install

# Pip install relevent packages.
# for newer pip you may need to drop the python3 -m from the start
python3 -m pip install pyproj
python3 -m pip install shapely

# Install HPCC python plugin. You'll need to select based on your OS/HPCCversion
# Below is for HPCC 6.4.24-1 on Ubuntu Xenial 64-bit
wget http://cdn.hpccsystems.com/releases/CE-Candidate-6.4.24/bin/plugins/hpccsystems-plugin-py3embed_6.4.24-1xenial_amd64.deb
dpkg -i hpccsystems-plugin-py3embed_6.4.24-1xenial_amd64.deb
apt-get install -f

# Download polygon tools python script from our repo so it's callable
wget https://raw.githubusercontent.com/OdinProAgrica/geodapper/master/polygonTools.py -P /opt/HPCCSystems/scripts/bin
chown hpcc /opt/HPCCSystems/scripts/bin/polygonTools.py
chgrp hpcc /opt/HPCCSystems/scripts/bin/polygonTools.py