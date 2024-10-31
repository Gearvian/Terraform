#!/bin/bash

# Variables
RUNNER_VERSION="2.320.0"
REPO_URL="https://github.com/Gearvian/Capestone"
GITHUB_TOKEN="ATFZKATYF77JEBX34DE6UZTHEHJU2" # Replace with your actual token
USER="gearvian"
RUNNER_DIR="/home/$USER/actions-runner"

# Exit immediately if a command exits with a non-zero status
set -e

# Step 1: Create a non-root user 'gearvian'
echo "Creating user: $USER"
if id "$USER" &>/dev/null; then
    echo "User $USER already exists, skipping creation."
else
    adduser --disabled-password --gecos "" $USER
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    echo "User $USER created."
fi

# Step 2: Install dependencies
echo "Installing dependencies..."
apt-get update
apt-get install -y curl sudo libicu-dev libssl-dev

# Step 3: Switch to non-root user and setup GitHub Actions runner
echo "Setting up GitHub Actions Runner..."

# Create the runner directory
sudo -u $USER mkdir -p $RUNNER_DIR
cd $RUNNER_DIR

# Download the runner
sudo -u $USER curl -o actions-runner-linux-x64-$RUNNER_VERSION.tar.gz -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz

# Extract the runner
sudo -u $USER tar xzf ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz

# Step 4: Configure the runner
echo "Configuring the runner..."
sudo -u $USER ./config.sh --url $REPO_URL --token $GITHUB_TOKEN

# Step 5: Install and start the runner service
echo "Installing and starting the runner as a service..."
sudo ./svc.sh install
sudo ./svc.sh start

echo "GitHub Actions Runner setup complete!"
