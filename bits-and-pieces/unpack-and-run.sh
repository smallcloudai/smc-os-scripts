#!/bin/bash
set -xe
cd /home/user
if [ -f unpack_code.py ]; then
    sudo --user=user --set-home --login /usr/local/miniconda/bin/python unpack_code.py
fi
if [ -f run_task.py ]; then
    sudo --user=user --set-home --login --background bash -c "nohup 2>&1 /usr/local/miniconda/bin/python run_task.py | tee --append /home/user/output.log"
fi
