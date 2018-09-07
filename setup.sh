#!/bin/sh

echo "Installing required packages"

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get -y install build-essential golang-1.10-go unzip redis-server nginx screen
sudo ln -s /usr/lib/go-1.10/bin/go /usr/local/bin/go
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo systemctl enable nginx
sudo systemctl enable redis


echo "Installing Roller Pool Software"

git clone https://github.com/roller-project/pool.git
cd pool
make all
sudo cp build/bin/open-ethereum-pool /usr/local/bin/roller-pool
sudo cp -R ./www /var/www/pool
sudo cp ./config.json /var/www/pool/config.json

echo "Done installing Roller Geth & Roller Pool Software!, Please configure your pool with the following instructions on https://roller.today"


echo '=========================='
echo 'Configuring pool service...'
echo '=========================='
cat > ~/pool.service << EOL
[Unit]
Description=Roller Pool

[Service]
ExecStart=/usr/local/bin/roller-pool /var/www/pool/config.json
Restart=always

[Install]
WantedBy=default.target
EOL

sudo \mv ~/pool.service /etc/systemd/system/pool.service
sudo systemctl enable pool

echo '=========================='
echo 'Configuring nginx service...'
echo '=========================='
cat > ~/pool-nginx.conf << EOL
upstream api {
	server 127.0.0.1:8080;
}

server {
	listen 0.0.0.0:80;

	root /var/www/pool/dist;
	index index.html index.htm;

	server_name localhost domain.com www.domain.com;

	location /api {
		proxy_pass http://api;
	}

	location / {
		try_files \$uri \$uri/ /index.html;
	}
}
EOL

sudo \mv ~/pool-nginx.conf /etc/nginx/sites-enabled/pool-nginx.conf
sudo systemctl restart nginx
