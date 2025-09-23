#!/bin/bash
# Stop script voor Week 1 project

echo "=== Stopping Week 1 Project ==="
echo "Stopping all containers..."

docker-compose down

echo "Containers stopped successfully."
echo ""
echo "To start again, run: ./start.sh"
echo "To remove all data, run: docker-compose down -v"
