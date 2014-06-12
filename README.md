stratos-dev-stack
=================

A single script for installing stratos.

1. Spawn an Ubuntu 12.04 instance.
2. Install git
   - sudo apt-get install git
3. Checkout Stratos Dev Stack
   - git clone https://github.com/imesh/stratos-dev-stack.git
4. Find host private ip address
5. Update following in install.sh file:
   - host_private_ip=""
   - ec2_identity=""
   - ec2_credential=""
   - ec2_keypair_name=""
   - ec2_owner_id=""
   - ec2_availability_zone=""
   - ec2_security_groups=""
6. Execute the installer
   - chmod +x install.sh
   - sudo ./install.sh
7. Once Stratos installation is ready create the cartridge base image using another Ubuntu 12.04 instance:
   - cd /tmp/
   - wget https://gist.githubusercontent.com/imesh/f8fd7a40d89dd4b60898/raw/48087c76b853632cf12474ba909bc355fe861666/cartridge-creator.sh
   - chmod +x cartridge-creator.sh
   - sudo ./cartridge-creator.sh
