#!/bin/bash
echo "AfterInstall: Starting..."
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html
echo "AfterInstall: Completed"