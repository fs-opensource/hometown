#!/usr/bin/env bash

# CockroachDB

if [ -f /home/vagrant/.hercules-installed/cockroachdb ]
then
    echo "CockroachDB is already installed"
    exit 0
fi

touch /home/vagrant/.hercules-installed/cockroachdb


## Install
sudo apt-get update
sudo apt-get install -y glibc libncurses

wget -qO- https://binaries.cockroachdb.com/cockroach-v2.0.6.linux-amd64.tgz | tar  xvz
sudo cp -i cockroach-v2.0.6.linux-amd64/cockroach /usr/local/bin

sudo mkdir /var/lib/cockroach
sudo useradd cockroach
sudo chown cockroach /var/lib/cockroach

## content for systemd cockroach.service
cockroachservice="
    [Unit]
    Description=Cockroach Database cluster node
    Requires=network.target

    [Service]
    Type=notify
    WorkingDirectory=/var/lib/cockroach
    ExecStart=/usr/local/bin/cockroach start --insecure --http-port=8090 --cache=.25 --max-sql-memory=.25
    TimeoutStopSec=60
    Restart=always
    RestartSec=10
    StandardOutput=syslog
    StandardError=syslog
    SyslogIdentifier=cockroach
    User=cockroach

    [Install]
    WantedBy=default.target
"

sudo echo "$cockroachservice" > /etc/systemd/system/cockroach.service


## Start
sudo systemctl restart cockroach
sudo systemctl enable cockroach
