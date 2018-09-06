#!/bin/sh
cd pool
git pull
make all
sudo cp build/bin/open-ethereum-pool /usr/local/bin/roller-pool
sudo systemctl restart pool
echo "Done Upgrading Roller geth & Roller Pool Software!"