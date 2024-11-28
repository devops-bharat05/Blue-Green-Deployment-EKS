#!/bin/bash

ehco " Updating...."
sudo apt-get update
sudo apt install unzip

echo "Installing Docker......."
sudo apt install docker.io -y
sudo systemctl status docker
echo "Installing Docker buildx......."
sudo apt install docker-buildx

echo "Add your user to the docker group:......."
sudo usermod -aG docker $USER

echo "Change the permissions of the Docker socket"
sudo chmod 666 /var/run/docker.sock
sudo systemctl restart docker


#AWS CLI Installation
echo "Installing AWS CLI......."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

#Helm Installation
echo "Installing Helm......."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -f get_helm.sh

#eksctl Installation
echo "Installing eksctl......."
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo mv /tmp/eksctl /usr/local/bin

# kubectl Installation
echo "Installing kubectl......."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
rm -f kubectl kubectl.sha256

# Validate Installations
echo "Validating installations......."
echo "AWS CLI Version:"
aws --version

echo "Helm Version:"
helm version --short

echo "eksctl Version:"
eksctl version

echo "kubectl Version:"
kubectl version

#Installing Terraform

echo "Starting Terraform installation.................. "

# Update system and install prerequisites
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common wget lsb-release

# Add the HashiCorp GPG key
echo "Installing the HashiCorp GPG key."
wget -q -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# Verify the GPG key fingerprint
echo "Verify the key's fingerprint."
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint || {
    echo "GPG key verification failed. Exiting."
    exit 1
}

# Add the HashiCorp repository
echo "Adding the HashiCorp repository."
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install Terraform
echo "Updating package lists and installing Terraform."
sudo apt-get update && sudo apt-get install -y terraform || {
    echo "Terraform installation failed. Exiting."
    exit 1
}

echo "Terraform installation completed successfully."

echo "Installation of all tools completed successfully!"
