#!/bin/bash
# Install Node.js if not installed
if ! command -v node &> /dev/null; then
    curl -sL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo yum install -y nodejs
fi

# Create app directory if it doesn't exist
if [ ! -d "/home/ec2-user/nodejs-demo-app" ]; then
    mkdir -p /home/ec2-user/nodejs-demo-app
fi

# Clean up existing files
rm -rf /home/ec2-user/nodejs-demo-app/* 