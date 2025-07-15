#!/bin/bash
# Update the system
yum update -y

# Install required packages
yum install -y ruby wget

# Install CodeDeploy agent
cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto
service codedeploy-agent status
service codedeploy-agent start

# Install Node.js
curl -sL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs npm

# Create application directory
mkdir -p /home/ec2-user/nodejs-demo-app
chown -R ec2-user:ec2-user /home/ec2-user/nodejs-demo-app

# Install PM2 globally
npm install -g pm2 