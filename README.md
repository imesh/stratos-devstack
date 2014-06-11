stratos-dev-stack
=================

A single script for installing stratos.

1. Spawn an Ubuntu 12.04 instance.
2. Install git
3. git clone https://github.com/imesh/stratos-dev-stack.git
4. Find host private ip address
5. Update following in install.sh file:
   host_private_ip=""
   
   ec2_identity=""
   ec2_credential=""
   ec2_keypair_name=""
   ec2_owner_id=""
   ec2_availability_zone=""
   ec2_security_groups=""
6. Run install.sh
