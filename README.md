stratos-dev-stack
=================

A single script for installing stratos.

1. Spawn an Ubuntu 12.04 instance

2. Update the system by running:
```bash
sudo apt-get update
```

3. Install git
```bash
sudo apt-get install git
```

4. Checkout Stratos Dev Stack
```bash
git clone https://github.com/imesh/stratos-dev-stack.git
```

5. Find the host's private IP address

6. Update following in the install.sh file:
```bash
host_private_ip=""
ec2_identity=""
ec2_credential=""
ec2_keypair_name=""
ec2_owner_id=""
ec2_availability_zone=""
ec2_security_groups=""
```

7. Execute the installer
```bash
chmod +x install.sh
sudo ./install.sh
```

8. Once the Stratos installation is ready, create the cartridge base image using another Ubuntu 12.04 instance:
```bash
cd /tmp/
wget https://gist.githubusercontent.com/imesh/f8fd7a40d89dd4b60898/raw/48087c76b853632cf12474ba909bc355fe861666/cartridge-creator.sh
chmod +x cartridge-creator.sh
sudo ./cartridge-creator.sh
```