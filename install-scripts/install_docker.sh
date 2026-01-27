#!/bin/bash
# install-scripts/install_docker.sh

echo "--- Installing Docker ---"
# Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo "SUCCESS: Docker is already installed."
else
    echo "INFO: Docker not found. Installing..."
    
    # Check if running on Ubuntu
    if [ "$(lsb_release -is)" = "Ubuntu" ]; then
        # Update your package index and install prerequisites:
        echo "INFO: Updating package index and installing prerequisites..."
        sudo apt update
        sudo apt install -y ca-certificates curl
        
        # Add Docker's official GPG key:
        echo "INFO: Adding Docker's official GPG key..."
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        
        # Add the Docker repository:
        echo "INFO: Adding Docker repository..."
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        
        # Install Docker Engine:
        echo "INFO: Installing Docker Engine..."
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        if [ $? -eq 0 ]; then
            echo "SUCCESS: Docker installed. Consider adding your user to the 'docker' group: sudo usermod -aG docker \$USER"
        else
            echo "ERROR: Failed to install Docker."
        fi
    else
        echo "WARNING: Not running on Ubuntu. Docker installation script may not work as expected."
        echo "Please refer to Docker's official documentation for your OS."
    fi
fi
echo "--------------------------"
