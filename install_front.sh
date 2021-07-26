#! /bin/bash
sudo apt-get update
sudo apt install -y nodejs
sudo apt install -y npm
sudo apt-get install -y git
git clone https://github.com/JuanFML/InterviewReactApp.git
cd InterviewReactApp
npm install
npm run start
