#!/bin/bash
cd /home/ec2-user/nodejs-demo-app || exit 1

# Ensure proper ownership
chown -R ec2-user:ec2-user /home/ec2-user/nodejs-demo-app

# Install dependencies
echo "Installing dependencies..."
npm install

# Install PM2 globally if not installed
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2..."
    npm install -g pm2
fi

# Stop any existing instance
echo "Stopping any existing application instance..."
pm2 stop nodejs-demo-app || true
pm2 delete nodejs-demo-app || true

# Start new instance
echo "Starting application..."
pm2 start app.js --name nodejs-demo-app
pm2 save

# Check if application started successfully
sleep 5
if pm2 list | grep -q "nodejs-demo-app"; then
    echo "Application started successfully"
    exit 0
else
    echo "Failed to start application"
    exit 1
fi 