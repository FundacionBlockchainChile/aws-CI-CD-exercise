#!/bin/bash
cd /home/ec2-user/nodejs-demo-app

# Install dependencies if needed
npm install

# Start the application using PM2
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
fi

# Stop any existing instance
pm2 stop nodejs-demo-app || true
pm2 delete nodejs-demo-app || true

# Start new instance
pm2 start app.js --name nodejs-demo-app

# Save PM2 configuration
pm2 save

# Print status
pm2 list 