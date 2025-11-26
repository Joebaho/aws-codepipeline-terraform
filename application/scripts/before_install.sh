#!/bin/bash
echo "BeforeInstall: Starting..."
sudo systemctl stop httpd || true
echo "BeforeInstall: Completed"