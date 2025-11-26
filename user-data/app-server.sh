#!/bin/bash
set -e

# Update and install dependencies
sudo yum -y update
sudo yum -y install ruby
sudo yum -y install wget
sudo yum -y install httpd

# Install CodeDeploy Agent
cd /home/ec2-user
wget https://aws-codedeploy-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Install AWS CLI
sudo yum -y install python3-pip
sudo pip3 install awscli

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Create web directory
sudo mkdir -p /var/www/html
sudo chown -R apache:apache /var/www/html

# Create a simple index.html file
sudo cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>CodeDeploy Project</title>
</head>
<body>
    <h1>Welcome to AWS CodeDeploy Project</h1>
    <p>This application was deployed using AWS CodeDeploy via CodePipeline.</p>
    <p>Environment: ${ENVIRONMENT}</p>
    <p>Version: Initial Deployment</p>
</body>
</html>
EOF

# Set permissions
sudo chmod -R 755 /var/www/html
sudo chown -R apache:apache /var/www/html

echo "User data script completed successfully"