stratos-devstack
=================

Stratos devstack provides a single script for installing Stratos on Amazon EC2. This script will download, install & configure Puppet Master, MySQL Server, ActiveMQ and Stratos on a single host. Stratos packages will be downloaded from the latest stable release. If required it can be point to a different version.

Please follow the below steps to install Stratos:

- Spawn an Ubuntu 12.04 instance. Use the below link to find the AMI-ID:
```
https://cloud-images.ubuntu.com/locator/ec2/
```

- Update the system and refresh repositories by running:
```bash
sudo apt-get update
```
- Install git
```bash
sudo apt-get install git
```
- Checkout Stratos Devstack
```bash
git clone https://github.com/imesh/stratos-dev-stack.git
```
- Find the host's private IP address

- Update following in the install.sh file:
```bash
host_private_ip="" # Private IP address of the Stratos host
ec2_identity="" # Find EC2 access key id from EC2 security credentials page [1]
ec2_credential="" # Find EC2 secret key from EC2 security credentials page [1]
ec2_keypair_name="" # Create a new keypair and add the keypair name here, ex: "us-east-key1.pem"
ec2_owner_id="" # Find the owner id from the AWS management console/instances/Stratos host instance [2]
ec2_availability_zone="" # Enter preferred EC2 availability zone, ex: "us-east-1a"
ec2_security_groups="" # Enter security group names, comma separated, ex: "all-tcp-udp-icmp"

# [1] https://console.aws.amazon.com/iam/home
# [2] https://console.aws.amazon.com/ec2/v2/home
```

- Execute the installer
```bash
chmod +x install.sh
sudo ./install.sh
```

- Once the Stratos installation is ready, spawn another Ubuntu 12.04 instance to create the base cartridge image.

- SSH into the above instance and execute the following command set. This will download the cartridge-creator.sh file and execute it in /tmp directory.
```bash
cd /tmp/
wget https://gist.githubusercontent.com/imesh/f8fd7a40d89dd4b60898/raw/48087c76b853632cf12474ba909bc355fe861666/cartridge-creator.sh
chmod +x cartridge-creator.sh
sudo ./cartridge-creator.sh
```

- The above script will ask for the following parameters:
  - Service name: Enter "default" to create the base cartridge image.
  - Puppet master IP: Enter the public IP address of the Stratos host.
  - Puppet master hostname: Enter "puppet.stratos.org", this is the hostname of the puppet master, in this installation puppet master is running in the Stratos host and it is given the above host name.
  
- Once the above process is complete go to the AWS management console/instances and create an image from the above instance. Make a note of the image id (AMI-ID), this needs to be specified in the cartridge definition.

- Now go to https://<stratos-host-public-ip>:9443/console and login using admin/admin. Use the Configuration Wizard to configure Stratos.
