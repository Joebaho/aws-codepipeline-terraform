#!/bin/bash
set -e

# Get the region from instance metadata
AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)


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
sudo systemctl start codedeploy-agent
sudo systemctl enable codedeploy-agent

# Install AWS CLI
sudo yum -y install python3-pip
sudo pip3 install awscli

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Wait for Apache to be fully ready
sleep 10

# Create web directory
sudo mkdir -p /var/www/html
sudo chown -R apache:apache /var/www/html

# Optional: Create a simple health check file if needed
echo "Healthy" | sudo tee /var/www/html/health.html

# Create a simple index.html file
sudo cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>CodeDeploy Project - CodePipeline</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { background: #232f3e; color: white; padding: 20px; border-radius: 5px; }
        .content { background: #f5f5f5; padding: 20px; border-radius: 5px; margin-top: 20px; }
        .success { color: #008000; }
        .info { color: #0066cc; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 AWS CodePipeline Deployment</h1>
        </div>
        <div class="content">
            <h2 class="success">✅ Deployment Successful!</h2>
            <p>This application was deployed using:</p>
            <ul>
                <li><strong>AWS CodePipeline</strong> - CI/CD Pipeline</li>
                <li><strong>AWS CodeBuild</strong> - Build Service</li>
                <li><strong>AWS CodeDeploy</strong> - Deployment Service</li>
                <li><strong>Terraform</strong> - Infrastructure as Code</li>
            </ul>
            <p class="info">Deployment triggered automatically on code changes to the GitHub repository.</p>
            <hr>
            <p><strong>Region:</strong> us-west-2 </p>
            <p><strong>Environment:</strong> Testing </p>
            <p><strong>Deployment Time:</strong> <span id="datetime"></span></p>
        </div>
    </div>
    
    <script>
        document.getElementById('datetime').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

# Set permissions
sudo chmod -R 755 /var/www/html
sudo chown -R apache:apache /var/www/html

echo "User data script completed successfully"