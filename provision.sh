# Installation de elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install -y apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install -y elasticsearch openjdk-8-jdk
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service

# Installation de kibana
sudo apt install -y nginx kibana
sudo su -c "echo 'server.host: \"localhost\"' >> /etc/kibana/kibana.yml"
sudo systemctl enable kibana
sudo systemctl start kibana

# Creation du reverse proxy
sudo apt install -y  apache2-utils
sudo htpasswd -b -c /etc/nginx/htpasswd.users admin admin
sudo htpasswd -b -c /etc/nginx/honeypot.users honeypot honeypot
sudo bash -c 'cat <<EOF>/etc/nginx/sites-available/kibana
server {
    listen 80;
    server_name stats.local.development;

    auth_basic "Acces interdit";
    auth_basic_user_file /etc/nginx/htpasswd.users;

    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade "$http_upgrade";
        proxy_set_header Connection "upgrade";
        proxy_set_header Host "$host";
        proxy_cache_bypass "$http_upgrade";
    }
}
EOF'

sudo bash -c 'cat <<EOF>/etc/nginx/sites-available/elasticsearch
server {
    listen 80;
    server_name elasticsearch.local.development;

    auth_basic "Acces interdit";
    auth_basic_user_file /etc/nginx/honeypot.users;

    location / {
        proxy_pass http://localhost:9200;
        proxy_http_version 1.1;
        proxy_set_header Upgrade "$http_upgrade";
        proxy_set_header Connection "upgrade";
        proxy_set_header Host "$host";
        proxy_cache_bypass "$http_upgrade";
    }
}
EOF'
sudo ln -s /etc/nginx/sites-available/kibana /etc/nginx/sites-enabled/kibana
sudo ln -s /etc/nginx/sites-available/elasticsearch /etc/nginx/sites-enabled/elasticsearch
sudo systemctl reload nginx