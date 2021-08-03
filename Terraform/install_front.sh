#! /bin/bash
sudo apt-get update
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install npm@latest -g
git clone https://github.com/JuanFML/InterviewReactApp.git
cd InterviewReactApp
npm install
npm run start