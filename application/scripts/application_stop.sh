#!/bin/bash
echo "ApplicationStop: Starting..."
sudo systemctl stop httpd || true
echo "ApplicationStop: Completed"