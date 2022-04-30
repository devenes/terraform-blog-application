#! /bin/bash

apt-get update -y
apt-get install git -y
apt-get install python3 -y
cd /home/ubuntu/
# TOKEN="*********************************"   # PLEASE ENTER YOUR TOKEN
# git clone https://$TOKEN@github.com/devenes/terraform-blog-application.git
git clone https://github.com/devenes/terraform-blog-application.git 
cd /home/ubuntu/terraform-blog-application  # PLEASE ENTER YOUR REPO PATH
apt install python3-pip -y
apt-get install python3.7-dev libmysqlclient-dev -y
pip3 install -r requirements.txt
cd /home/ubuntu/terraform-blog-application/src  # PLEASE ENTER YOUR REPO PATH
python3 manage.py collectstatic --noinput
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py runserver 0.0.0.0:80
