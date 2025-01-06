#!/bin/bash
# jenkins.sh

# Example: Install Docker (if Jenkins needs Docker)
apt-get update -y
apt-get install -y docker.io
usermod -aG docker jenkins

# Restart Jenkins to apply any changes
sudo systemctl restart jenkins
