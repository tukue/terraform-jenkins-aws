#!/bin/bash

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check command status
check_status() {
    if [ $? -eq 0 ]; then
        log "SUCCESS: $1"
    else
        log "ERROR: $1"
        exit 1
    fi
}

# Must run as root
if [ "$EUID" -ne 0 ]; then
    log "Please run as root (use sudo)"
    exit 1
fi

# Step 1: Stop and remove existing Jenkins
log "Stopping and removing existing Jenkins installation..."
systemctl stop jenkins || true
apt remove jenkins -y || true
apt purge jenkins -y || true

# Step 2: Clean up Jenkins directories
log "Cleaning up Jenkins directories..."
rm -rf /var/lib/jenkins
rm -rf /var/cache/jenkins
rm -rf /var/log/jenkins
rm -rf /etc/default/jenkins

# Step 3: Update system and install Java 11
log "Installing Java 11..."
apt update
check_status "System update"

apt remove openjdk* -y || true
apt autoremove -y
apt install openjdk-11-jdk-headless -y
check_status "Java 11 installation"

# Step 4: Set JAVA_HOME
log "Setting JAVA_HOME..."
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "JAVA_HOME=$JAVA_HOME" | tee -a /etc/environment
source /etc/environment
check_status "JAVA_HOME configuration"

# Step 5: Install Jenkins
log "Installing Jenkins..."
wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
check_status "Jenkins key download"

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
check_status "Jenkins repository configuration"

apt update
apt install jenkins -y
check_status "Jenkins installation"

# Step 6: Create and set permissions for Jenkins directories
log "Setting up Jenkins directories and permissions..."
mkdir -p /var/lib/jenkins
mkdir -p /var/cache/jenkins
mkdir -p /var/log/jenkins

chown -R jenkins:jenkins /var/lib/jenkins
chown -R jenkins:jenkins /var/cache/jenkins
chown -R jenkins:jenkins /var/log/jenkins

chmod 755 /var/lib/jenkins
chmod 755 /var/cache/jenkins
chmod 755 /var/log/jenkins
check_status "Directory permissions setup"

# Step 7: Enable and start Jenkins
log "Starting Jenkins..."
systemctl enable jenkins
systemctl start jenkins
check_status "Jenkins service startup"

# Step 8: Check Jenkins status
log "Checking Jenkins status..."
systemctl status jenkins

# Step 9: Display initial admin password
log "Waiting for Jenkins to generate the initial admin password (this may take a minute)..."
sleep 30
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    echo "Jenkins initial admin password:"
    cat /var/lib/jenkins/secrets/initialAdminPassword
else
    log "Initial admin password not found. Please check Jenkins logs for issues."
fi

# Step 10: Display useful information
log "Installation complete!"
echo "Jenkins should be accessible at: http://localhost:8080"
echo "Check status with: sudo systemctl status jenkins"
echo "View logs with: sudo journalctl -u jenkins"