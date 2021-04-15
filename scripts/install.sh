#!/bin/bash

set -e
set -x

dkms_name="hid-magicmouse-dkms"
dkms_version="4.18+magictrackpad2"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# To see the logs:
# sudo tail -f /var/log/kern.log

# compile
echo "------------ COMPILING SOURCE CODE ------------"
cd ${DIR}/../linux/drivers/hid
make clean
make all

# add
echo "------------ ADDING DKMS MODULE ------------"
if ! dkms status -m $dkms_name -v $dkms_version | egrep '(added|built|installed)' >/dev/null ; then
  dkms add ${DIR}/../linux/drivers/hid
fi

# build
echo "------------ BUILDING DKMS MODULE ------------"
if ! dkms status -m $dkms_name -v $dkms_version  | egrep '(built|installed)' >/dev/null ; then
  dkms build $dkms_name/$dkms_version
fi

# install
echo "------------ INSTALLING DKMS MODULE ------------"
if ! dkms status -m $dkms_name -v $dkms_version  | egrep '(installed)' >/dev/null; then
  dkms install --force $dkms_name/$dkms_version
fi

# load the DKMS module
rmmod hid_magicmouse
insmod /lib/modules/$(uname -r)/extra/hid-magicmouse.ko
