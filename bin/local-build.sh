#!/bin/bash

# see `install.sh` first

cd /home/labile/agentgateway-insider

source .venv/bin/activate

export http_proxy=http://192.168.16.58:8118 && export https_proxy=http://192.168.16.58:8118

cd /home/labile/agentgateway-insider
pushd ./docs
make clean
make html
popd
google-chrome $(pwd)/docs/build/html/index.html