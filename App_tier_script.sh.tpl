#!/bin/bash


# All output will be redirected to mylogfile.log

# Set log file
LOGFILE="/var/log/user-data.log"
LOGFILE_Func="/var/log/logfun.log"
exec > "$LOGFILE" 2>&1
# Function to log messages
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE_Func"
}
DB_Pass="Welcome\$1041"
# Start logging
log_message "Starting user data script and switching to root user"
sudo su -
#Updating system
log_message "Updating packages"
if yum check-update -q; then
  sudo yum update -y
  if [ $? -eq 0 ]; then
      log_message "yum update succeeded."
  else
      log_message "yum update failed with exit status $?."
  fi
else 
  log_message "No updates available"
fi  

#Installing mysql client

if ! rpm -q mysql > /dev/null; then
    log_message "Installing mysql client"
    # Install the MySQL client
    sudo yum install -y mysql
    if [ $? -eq 0 ]; then
       log_message "yum install mysql succeeded."
    else
       log_message "yum install mysql failed with exit status $?."
    fi
else
    log_message "MySQL client is already installed."
fi

# Verify MySQL client installation
if which mysql > /dev/null; then
    log_message "MySQL client installation verified."
else
    log_message "MySQL client installation failed."
fi

#Setting up connection to database
log_message "Setting up connection to  - ${RDS_endpoint}"
mysql -h ${RDS_endpoint} -u admin -p"$DB_Pass" <<EOF
CREATE DATABASE IF NOT EXISTS web_app_db;
USE web_app_db;
CREATE TABLE IF NOT EXISTS transactions (
    id INT NOT NULL AUTO_INCREMENT,
    amount DECIMAL(10,2),
    description VARCHAR(100),
    PRIMARY KEY(id)
);
INSERT INTO transactions (amount, description) VALUES (400, 'groceries');
EOF

if [ $? -eq 0 ]; then
    log_message "Connection to RDS instance succeeded."
else
    log_message "Connection to RDS instance failed with exit status $?."
fi




#install node and npc
log_message "Installing node, npm and pm2server -3"

# Create the .nvm directory if it doesn't exist
mkdir -p /root/.nvm
if [ $? -ne 0 ]; then
    log_message "Failed to create /root/.nvm directory. Exiting."
else
    log_message ".NVM directory created successfully"
fi

# Ensure profile file exists
PROFILE_FILE="/root/.bashrc"
if [ ! -f $PROFILE_FILE ]; then
    touch $PROFILE_FILE
fi


# Download and install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

if [ $? -ne 0 ]; then
    echo "Failed to download or install NVM. Exiting."
else
    log_message "NVM file downloaded successfully"
fi

# Add NVM configuration to the profile
echo 'export NVM_DIR="$HOME/.nvm"' >> $PROFILE_FILE
if [ $? -ne 0 ]; then
    log_message "Failed to write NVM_DIR to $PROFILE_FILE. Exiting."
else
    log_message "NVM_DIR written to .bashrc successfully"
fi

echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> $PROFILE_FILE
if [ $? -ne 0 ]; then
    log_message "Failed to write NVM_DIR/nvm.sh to $PROFILE_FILE. Exiting."
else
    log_message "NVM_DIR/nvm.sh written to .bashrc successfully"
fi

# Source the profile to apply changes
. $PROFILE_FILE
if [ $? -ne 0 ]; then
    log_message "Failed to source $PROFILE_FILE. Exiting."
else
    log_message "$PROFILE_FILE sourced successfully"
fi

# Install Node.js and npm using NVM
nvm install 16
if [ $? -ne 0 ]; then
    log_message "Failed to install Node.js 16. Exiting."
else
    log_message "Node.js installed successfully"
fi
log_message "Node.js path: $(which node)"
log_message "NPM path: $(which npm)"

# switching to node successfully
nvm use 16
if [ $? -ne 0 ]; then
    log_message "Failed to switch to Node.js 16. Exiting."
else
    log_message "Switched to Node.js  successfully"
fi

# Install pm2 globally
npm install -g pm2
if [ $? -ne 0 ]; then
    log_message "Failed to install PM2 globally. Exiting."
else
    log_message "PM2 installed successfully"
fi
log_message "PM2 path: $(which pm2)"
log_message "Node, npm, and pm2 installed successfully"
 
# Making installation of NODE,npm,PM2 global and available to next session
NODE_BIN=$(nvm which current | xargs dirname)
echo "export PATH=$NODE_BIN:$PATH" >> /etc/profile.d/nodejs.sh
source /etc/profile.d/nodejs.sh

echo 'export NVM_DIR="$HOME/.nvm"' >> /etc/profile
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /etc/profile
source /etc/profile

#Copy code from s3 to local folder
log_message "Copying code from s3 bucket"
cd ~/
aws s3 cp s3://tusharmalik77/application-code/app-tier/ app-tier --recursive

if [ $? -eq 0 ]; then
    log_message "Code copied successfull"
else
    log_message "Code did not get fetched due to  - exit status $?."
fi

#edit DbConfig.js file with latest created database endpoint
log_message "Updating DbConfig.js file"
echo "module.exports = Object.freeze({
    DB_HOST : '${RDS_endpoint}',
    DB_USER : 'admin',
    DB_PWD : 'Welcome\$1041',
    DB_DATABASE : 'web_app_db'
});" > app-tier/DbConfig.js

if [ $? -eq 0 ]; then
    log_message "File updates successfully with latest DB credentials"
else
    log_message "Unable to update db credentials  - exit status $?."
fi



#Navigate to app directory and instal dependencies
log_message "Changing directory to app_tier and starting server"
cd ~/app-tier
if [ ! -f index.js ]; then
    log_message "Error: index.js file not found."
fi

log_message "Installing npm dependencies"
npm install
if [ $? -ne 0 ]; then
    log_message "Error: npm install failed."
fi

pm2 start index.js
if [ $? -ne 0 ]; then
    log_message "Error: pm2 failed to start the application."
else
    log_message "pm2 successfully started the application."
fi




