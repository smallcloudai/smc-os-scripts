#!/bin/bash
set -xe
if [ -b /dev/mapper/throwawaykey ]; then
    exit 0
fi
# Works as assert to make sure /dev/vdb exists:
ls /dev/vd* | grep vdb
throwawaykey=`openssl rand -hex 32`
dmsetup create throwawaykey --table "0 `blockdev --getsz /dev/vdb` crypt aes-cbc-essiv:sha256 $throwawaykey 0 /dev/vdb 0"
#                                                                        <cipher>             <key>         <iv_offset> <device path> <offset> [<#opt_params> <opt_params>]
mkfs.ext4 /dev/mapper/throwawaykey
tar -czf /tmp/homes.tar.gz /home
mount /dev/mapper/throwawaykey /home
tar -xzf /tmp/homes.tar.gz -C /
echo "Successfully mounted encrypted home"
rm /tmp/homes.tar.gz

# To destroy data:
# umount /home; dmsetup remove_all --force
