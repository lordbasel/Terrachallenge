#! /bin/bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo reboot