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
host_private_ip=""
ec2_identity=""
ec2_credential=""
ec2_keypair_name=""
ec2_owner_id=""
ec2_availability_zone=""
ec2_security_groups=""
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