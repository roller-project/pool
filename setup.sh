#!/usr/bin/env sh
vPATH = ~
sudo aput-get -y update
sudo apt-get install -y nodejs nodejs-legacy npm redis-server nginx autoconf automake build-essential python-dev
sudo apt-get install -y libssl-dev git curl screen unzip wget
sudo curl -O https://storage.googleapis.com/golang/go1.9.7.linux-amd64.tar.gz
sudo tar -xvf go1.9.7.linux-amd64.tar.gz
sudo mv go /usr/local
sudo echo 'export PATH=$PATH:/usr/local/go/bin' > ~/.profile
source ~/.profile
cd ~
git clone https://github.com/roller-project/pool.git
cd ~/pool
sudo make
sudo mv ~/build/bin/open-ethereum-pool ~/build/bin/roller-pool
sudo chmod +x  ~/build/bin/roller-pool
#enable service
sudo systemctl enable nginx
sudo systemctl enable redis

cd ~

echo '=========================='
echo 'Configuring pool service...'
echo '=========================='
cat > ~/pool.service << EOL
[Unit]
Description=Roller Pool

[Service]
ExecStart=${vPATH}/build/bin/roller-pool ${vPATH}/config.json
Restart=always

[Install]
WantedBy=default.target
EOL


echo '=========================='
echo 'Configuring nginx service...'
echo '=========================='
cat > ~/pool-nginx.conf << EOL
upstream api {
	server 127.0.0.1:8080;
}

server {
	listen 0.0.0.0:80;

	root ${vPATH}/pool/www/dist;
	index index.html index.htm;

	server_name localhost domain.com www.domain.com;

	location /api {
		proxy_pass http://api;
	}

	location / {
		try_files $uri $uri/ /index.html;
	}
}
EOL
