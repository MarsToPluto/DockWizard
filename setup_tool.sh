#!/bin/bash

# Load constants from .PLUTO file
if [ -f .PLUTO ]; then
    source .PLUTO
else
    echo ".PLUTO file not found! Please create it with the necessary configuration."
    exit 1
fi

# Function to install Docker and Docker Compose
install_docker() {
    echo "Installing Docker and Docker Compose..."
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    sudo systemctl enable docker
    sudo systemctl start docker

    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    echo "Docker and Docker Compose installed successfully!"
}

# Function to set up Jenkins
setup_jenkins() {
    echo "Setting up Jenkins..."
    mkdir -p ~/jenkins && cd ~/jenkins
    cat <<EOF > docker-compose.jenkins.yml
version: '3.8'
services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
    restart: always

volumes:
  jenkins_home:
EOF
    docker-compose up -d
    echo "Jenkins is running at http://localhost:8080"
    echo "Initial Admin Password:"
    sleep 10  # Wait for Jenkins to start
    sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
}

# Function to generate Nginx configuration
generate_nginx_conf() {
    echo "Creating Nginx configuration..."
    
    read -p "Enter your domain name (default: $DOMAIN_NAME): " input_domain_name
    domain_name=${input_domain_name:-$DOMAIN_NAME}
    
    read -p "Enter the Jenkins URL (default: $JENKINS_URL): " input_jenkins_url
    jenkins_url=${input_jenkins_url:-$JENKINS_URL}

    cat <<EOF > nginx.conf
server {
    listen 80;
    server_name $domain_name;

    location / {
        proxy_pass $jenkins_url;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}

server {
    listen 443 ssl;
    server_name $domain_name;

    ssl_certificate /etc/letsencrypt/live/$domain_name/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain_name/privkey.pem;

    location / {
        proxy_pass $jenkins_url;
    }
}
EOF
    echo "Nginx configuration created."
}

# Function to set up Nginx with Certbot
setup_nginx() {
    echo "Setting up Nginx with Certbot..."
    mkdir -p ~/nginx && cd ~/nginx
    generate_nginx_conf
    cat <<EOF > docker-compose.nginx.yml
version: '3.8'

services:
  nginx:
    image: nginx:latest
    container_name: nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - cert_data:/etc/letsencrypt
    depends_on:
      - jenkins
    restart: always

  certbot:
    image: certbot/certbot
    volumes:
      - cert_data:/etc/letsencrypt
      - ./certbot/renew.sh:/usr/local/bin/renew.sh
    entrypoint: "/usr/local/bin/renew.sh"

volumes:
  cert_data:
EOF

    # Create Certbot renewal script
    mkdir -p ~/nginx/certbot
    cat <<EOF > ~/nginx/certbot/renew.sh
#!/bin/bash

# Wait for Nginx to be up and running
sleep 20

# Obtain or renew the SSL certificate
certbot certonly --webroot --webroot-path=/var/www/certbot -d $domain_name --non-interactive --agree-tos --email your_email@example.com

# Start Nginx
nginx -g "daemon off;"
EOF

    chmod +x ~/nginx/certbot/renew.sh
    docker-compose up -d
}

# Function to install MySQL
install_mysql() {
    echo "Installing MySQL..."
    mkdir -p ~/mysql && cd ~/mysql
    cat <<EOF > docker-compose.mysql.yml
version: '3.8'

services:
  mysql:
    image: mysql:latest
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD
      MYSQL_DATABASE: $MYSQL_DATABASE
      MYSQL_USER: $MYSQL_USER
      MYSQL_PASSWORD: $MYSQL_PASSWORD
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    restart: always

volumes:
  mysql_data:
EOF
    docker-compose up -d
    echo "MySQL is running on port 3306."
}

# Function to install MongoDB
install_mongodb() {
    echo "Installing MongoDB..."
    mkdir -p ~/mongodb && cd ~/mongodb
    cat <<EOF > docker-compose.mongodb.yml
version: '3.8'

services:
  mongodb:
    image: mongo:latest
    container_name: mongodb
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
    restart: always

volumes:
  mongo_data:
EOF
    docker-compose up -d
    echo "MongoDB is running on port 27017."
}

# Function to create .env file
create_env_file() {
    echo "Creating .env file..."
    {
        echo "DOMAIN_NAME=$DOMAIN_NAME"
        echo "JENKINS_URL=$JENKINS_URL"
        echo "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD"
        echo "MYSQL_DATABASE=$MYSQL_DATABASE"
        echo "MYSQL_USER=$MYSQL_USER"
        echo "MYSQL_PASSWORD=$MYSQL_PASSWORD"
        echo "MONGODB_URL=$MONGODB_URL"
    } > .env
    echo ".env file created with the following values:"
    cat .env
}

# Function to skip steps based on user input
prompt_user() {
    read -p "Do you want to install Docker and Docker Compose? (y/n): " install_docker_choice
    if [[ "$install_docker_choice" == "y" ]]; then
        install_docker
    fi

    read -p "Do you want to set up Jenkins? (y/n): " setup_jenkins_choice
    if [[ "$setup_jenkins_choice" == "y" ]]; then
        setup_jenkins
    fi

    read -p "Do you want to set up Nginx with Certbot? (y/n): " setup_nginx_choice
    if [[ "$setup_nginx_choice" == "y" ]]; then
        setup_nginx
    fi

    read -p "Do you want to install MySQL? (y/n): " install_mysql_choice
    if [[ "$install_mysql_choice" == "y" ]]; then
        install_mysql
    fi

    read -p "Do you want to install MongoDB? (y/n): " install_mongodb_choice
    if [[ "$install_mongodb_choice" == "y" ]]; then
        install_mongodb
    fi

    # Create .env file after installations
    create_env_file

    echo "Setup complete!"
}

# Start the script
echo "Welcome to the automated setup tool!"
prompt_user
