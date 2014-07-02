stratos-dev-stack
=================

A single script for installing stratos.

- Spawn an Ubuntu 12.04 instance

- Update the system and refresh repositories by running:
```bash
sudo apt-get update
```
- Install git
```bash
sudo apt-get install git
```
- Checkout Stratos Dev Stack
```bash
git clone https://github.com/imesh/stratos-dev-stack.git
```
- Find the host's private IP address

- Update following in the install.sh file:
```bash
host_private_ip="" # Private IP address of the Stratos host
ec2_identity="" # Find EC2 access key id from EC2 security credentials page [1]
ec2_credential="" # Find EC2 secret key from EC2 security credentials page [1]
ec2_keypair_name="" # Create a new keypair and add the keypair name here
ec2_owner_id="" # Find the owner id from the EC2 console [1]
ec2_availability_zone="" # Enter preferred EC2 availability zone
ec2_security_groups="" # Enter security group names, comma separated

# [1] https://console.aws.amazon.com/iam/home
```

- Execute the installer
```bash
chmod +x install.sh
sudo ./install.sh
```

- Once the Stratos installation is ready, create the cartridge base image using another Ubuntu 12.04 instance:
```bash
cd /tmp/
wget https://gist.githubusercontent.com/imesh/f8fd7a40d89dd4b60898/raw/48087c76b853632cf12474ba909bc355fe861666/cartridge-creator.sh
chmod +x cartridge-creator.sh
sudo ./cartridge-creator.sh
```
