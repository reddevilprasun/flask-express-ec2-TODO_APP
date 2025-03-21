#!/bin/bash

sudo apt-get update
sudo apt-get install -y python3-pip python3

# Install Git
sudo apt-get install -y git

# Clone the repository
cd /home/ubuntu
git clone https://github.com/reddevilprasun/flask-express-ec2-TODO_APP.git
cd flask-express-ec2-TODO_APP

sudo chmod 777 /home/ubuntu/flask-express-ec2-TODO_APP/backend

cd backend
sudo apt install -y python3.12-venv
python3 -m venv venv
source venv/bin/activate
sudo touch .env
echo "MONGO_URL=mongodb+srv://prasunpersonal:*******@prasunpersonal.qze2n.mongodb.net/?retryWrites=true&w=majority" | sudo tee .env
pip3 install -r requirements.txt

nohup gunicorn --bind 0.0.0.0:5000 app:app > flask.log 2>&1 &

sudo chmod 777 /home/ubuntu/flask-express-ec2-TODO_APP/backend/flask.log