#!/usr/bin/env bash

/etc/init.d/hpcc-init start
echo "HPCC is running. Going to sleep forever....."
tail -f /dev/null