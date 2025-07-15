#!/bin/bash
# Install Node.js if not installed
if ! command -v node &> /dev/null; then
    curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
    sudo yum install -y nodejs
fi

# Create app directory if it doesn't exist
if [ ! -d "/home/ec2-user/nodejs-demo-app" ]; then
    mkdir -p /home/ec2-user/nodejs-demo-app
fi

# Set proper permissions
chown -R ec2-user:ec2-user /home/ec2-user/nodejs-demo-app

# Clean up existing files
rm -rf /home/ec2-user/nodejs-demo-app/* 