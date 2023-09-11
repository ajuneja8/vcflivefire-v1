#!/bin/bash

# Clone the GitHub repository
git clone https://github.com/ajuneja8/vcflivefire-v1.git

# Change directory to the cloned repository
cd vcflivefire-v1

# Sleep for 5 seconds
sleep 5

# Create directories
mkdir create-topology t0-uplink-bgp-sck t0-uplink-bgp-cmi

# Copy files to the respective directories
cp 1-create-stretched-topology.tf ~/vcflivefire-v1/create-topology/
cp 2-create-t0-uplink-bgp-sck.tf ~/vcflivefire-v1/t0-uplink-bgp-sck/
cp 3-create-t0-uplink-bgp-cmi.tf ~/vcflivefire-v1/t0-uplink-bgp-cmi/

# Change directory to create-topology, list files, and run terraform commands
cd create-topology
echo "Files in create-topology directory:"
ls -l
terraform init
terraform apply -auto-approve

# Sleep for 5 seconds
sleep 5

# Change directory to t0-uplink-bgp-sck, list files, and run terraform commands
cd ~/vcflivefire-v1/t0-uplink-bgp-sck
echo "Files in t0-uplink-bgp-sck directory:"
ls -l
terraform init
terraform apply -auto-approve

# Sleep for 5 seconds
sleep 5

# Change directory to t0-uplink-bgp-cmi, list files, and run terraform commands
cd ~/vcflivefire-v1/t0-uplink-bgp-cmi
echo "Files in t0-uplink-bgp-cmi directory:"
ls -l
terraform init
terraform apply -auto-approve

# Sleep for a final 5 seconds
sleep 5
