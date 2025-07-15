#!/bin/bash
# Wait for the application to be available
sleep 10

# Check if the application is responding
response=$(curl -s http://localhost:3000)
if [[ "$response" == *"Hello from AWS CI/CD Pipeline"* ]]; then
    echo "Application is running successfully!"
    exit 0
else
    echo "Application is not running properly"
    exit 1
fi 