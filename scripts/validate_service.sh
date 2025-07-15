#!/bin/bash
# Wait for the application to be available
sleep 10

# Check if the application is responding
response=$(curl -s http://localhost:3000)
if [[ "$response" == *"¡Hola! Esta es una prueba del pipeline CI/CD en AWS"* ]]; then
    echo "Application is running successfully!"
    exit 0
else
    echo "Application is not running properly"
    exit 1
fi 