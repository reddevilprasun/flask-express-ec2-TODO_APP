#!/bin/bash

sudo apt-get update

# Install Node.js and npm
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo apt-get install -y git

# Clone the repository
cd /home/ubuntu
git clone https://github.com/reddevilprasun/flask-express-ec2-TODO_APP.git
cd flask-express-ec2-TODO_APP

sudo chmod 777 /home/ubuntu/flask-express-ec2-TODO_APP/frontend

cd frontend
sudo touch .env
echo "BACKEND_URL=http://localhost:5000" | sudo tee .env
sudo npm install

nohup npm start > react.log 2>&1 &

sudo chmod 777 /home/ubuntu/flask-express-ec2-TODO_APP/frontend/react.log