#!/bin/bash
# ------------------------------------------------------------------
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing,
#  software distributed under the License is distributed on an
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied.  See the License for the
#  specific language governing permissions and limitations
#  under the License.
# ------------------------------------------------------------------
# Description: Use this script to install Stratos on a single host.
#
# Author: imesh@apache.org
# ------------------------------------------------------------------

set -e # terminate on any error

# Configuration parameters start
host_user="ubuntu"
host_private_ip="127.0.0.1"
host_user_home="/home/ubuntu"

ec2_identity=""
ec2_credential=""
ec2_keypair_name=""
ec2_owner_id=""
ec2_availability_zone=""
ec2_security_groups=""

jdk_tar_file="jdk-7u55-linux-x64.tar.gz"
jdk_folder=jdk1.7.0_55
java_home="/opt/${jdk_folder}"
jdk_download_url="http://download.oracle.com/otn-pub/java/jdk/7u55-b13/${jdk_tar_file}"

mysql_host="localhost"
mysql_username="root"
mysql_password="mysql"
mysql_root_password="mysql"
mysql_connector_java="mysql-connector-java-5.1.31"
mysql_connector_download_url="http://dev.mysql.com/get/Downloads/Connector-J/${mysql_connector_java}.tar.gz"

stratos_version=4.0.0-rc4
stratos_dist_path=https://dist.apache.org/repos/dist/dev/stratos/${stratos_version}
stratos_packages_path=${host_user_home}"/stratos-packages"
stratos_source_path=${host_user_home}"/stratos-source"
stratos_installer_path=${host_user_home}"/stratos-installer"
stratos_path=${host_user_home}"/stratos"
stratos_domain_name="stratos.org"

activemq_tar_file="apache-activemq-5.9.1-bin.tar.gz"
activemq_download_url="http://apache.spinellicreations.com/activemq/5.9.1/apache-activemq-5.9.1-bin.tar.gz"
activemq_lib_path=${stratos_packages_path}/"apache-activemq-5.9.1/lib"
activemq_lib_required="activemq-broker-5.9.1.jar activemq-client-5.9.1.jar geronimo-j2ee-management_1.1_spec-1.0.1.jar geronimo-jms_1.1_spec-1.1.1.jar hawtbuf-1.9.jar"

puppet_installer_path=${host_user_home}"/puppet-installer"
puppet_master_path=/etc/puppet
puppet_hostname="puppet."${stratos_domain_name}
nodes_pp_path=${puppet_master_path}/manifests/nodes.pp

stratos_source_folder="apache-stratos-4.0.0-source-release"
stratos_source_package="apache-stratos-4.0.0-source-release.zip"
stratos_package="apache-stratos-4.0.0.zip"
stratos_ca_package="apache-stratos-cartridge-agent-4.0.0.zip"
stratos_cli_package="apache-stratos-cli-4.0.0.zip"
stratos_haproxy_package="apache-stratos-haproxy-extension-4.0.0.zip"
stratos_lb_package="apache-stratos-load-balancer-4.0.0.zip"

stratos_ca_package_path=${stratos_packages_path}/${stratos_ca_package}
stratos_lb_package_path=${stratos_packages_path}/${stratos_lb_package}
# Configuration parameters end

download_jdk=true
install_jdk=true
install_mysql_server=true
download_mysql_connector=true
install_zip=true
download_stratos_packs=true
download_activemq_pack=true
copy_stratos_source=true
install_puppet_master=true
copy_puppet_scripts=true
copy_activemq_client_libs=true
copy_packages_to_puppet_modules=true
copy_jdk_to_puppet_modules=true
update_nodes_pp_file=true
prepare_installer=true
start_installer=true

log=install.log

if [ ${download_jdk} = true ]; then
	pushd /opt
	echo "Downloading jdk" | tee -a ${log}
	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" ${jdk_download_url}
	popd
fi

if [ ${install_jdk} = true ]; then
	pushd /opt
	echo "Extracting jdk" | tee -a ${log}
	tar -zxvf ${jdk_tar_file}

	echo "Updating .bashrc" | tee -a ${log}
	echo "" >> ${host_user_home}/.bashrc
	echo "JAVA_HOME=${java_home}" >> ${host_user_home}/.bashrc
	echo "PATH=$PATH:$JAVA_HOME/bin" >> ${host_user_home}/.bashrc
	echo "export JAVA_HOME" >> ${host_user_home}/.bashrc
	popd
fi

if [ ${download_stratos_packs} = true ]; then
	echo "Downloading stratos packages" | tee -a ${log}
	mkdir -p ${stratos_packages_path}
	pushd ${stratos_packages_path}
   
	echo "Downloading source release" | tee -a ${log}
	wget ${stratos_dist_path}/${stratos_source_package}
 
	echo "Downloading stratos package" | tee -a ${log}
	wget ${stratos_dist_path}/${stratos_package}
 
	echo "Downloading cartridge agent package" | tee -a ${log}
	wget ${stratos_dist_path}/${stratos_ca_package}
 
	echo "Downloading cli package" | tee -a ${log}
	wget ${stratos_dist_path}/${stratos_cli_package}
 
	echo "Downloading haproxy package" | tee -a ${log}
	wget ${stratos_dist_path}/${stratos_haproxy_package}
 
	echo "Downloading load balancer package" | tee -a ${log}
	wget ${stratos_dist_path}/${stratos_lb_package}
 
	echo "Download completed" | tee -a ${log}
	popd
fi

if [ ${download_activemq_pack} = true ]; then
	mkdir -p ${stratos_packages_path}
	pushd ${stratos_packages_path}
	wget ${activemq_download_url}
	popd
fi

if [ ${install_mysql_server} = true ]; then
	echo "Installing MySQL server" | tee -a ${log}
	#debconf-set-selections <<< 'mysql-server mysql-server/root_password password ${mysql_root_password}'
	#debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password ${mysql_root_password}'
	export DEBIAN_FRONTEND=noninteractive
	apt-get -q -y install mysql-server
	mysqladmin -u root password ${mysql_root_password}
fi

if [ ${download_mysql_connector} = true ]; then	
	echo "Downloading mysql connector for java" | tee -a ${log}
	mkdir -p ${stratos_packages_path} 
	pushd ${stratos_packages_path}
	wget ${mysql_connector_download_url}
	tar -zxvf ${mysql_connector_java}.tar.gz
	cp ${mysql_connector_java}/${mysql_connector_java}-bin.jar .
	rm -rf ${mysql_connector_java}/
	popd
fi

if [ ${install_zip} = true ]; then
	echo "Installing zip" | tee -a ${log}
	apt-get -y install zip
fi

if [ ${copy_stratos_source} = true ]; then
	if [ -d ${stratos_source_path} ]; then
		echo "Removing existing source folder" | tee -a ${log}
		rm -rf ${stratos_source_path}
	fi
	mkdir -p ${stratos_source_path}
	echo "Extracting source package" | tee -a ${log}
	pushd ${stratos_packages_path}
	if [ -d /tmp/${stratos_source_folder} ]; then
		rm -rf /tmp/${stratos_source_folder}
	fi
	unzip ${stratos_source_package} -d /tmp/
	mv /tmp/${stratos_source_folder}/* ${stratos_source_path}/
	rm -rf /tmp/${stratos_source_folder}
	popd
fi

if [ ${install_puppet_master} = true ]; then
	echo "Installing puppet master" | tee -a ${log}
	mkdir -p ${puppet_installer_path}
	pushd ${puppet_installer_path}
	git clone https://github.com/thilinapiy/puppetinstall .
	./puppetinstall -y -m -d ${stratos_domain_name} -s ${host_private_ip}
	popd
fi

if [ ${copy_puppet_scripts} = true ]; then
	echo "Copying puppet scripts" | tee -a ${log}
	pushd /etc/puppet/
	cp -rv ${stratos_source_path}/tools/puppet3/manifests/* manifests/
	cp -rv ${stratos_source_path}/tools/puppet3/modules/* modules/
	popd
fi

if [ ${copy_activemq_client_libs} = true ]; then
	echo "Copying activemq client libraries" | tee -a ${log} 
	pushd ${stratos_packages_path}
	tar -zxvf ${activemq_tar_file}
	pushd ${activemq_lib_path}
	mkdir -p /etc/puppet/modules/agent/files/activemq
	mkdir -p /etc/puppet/modules/lb/files/activemq
	cp -v ${activemq_lib_required} /etc/puppet/modules/agent/files/activemq
	cp -v ${activemq_lib_required} /etc/puppet/modules/lb/files/activemq
	popd
	popd
fi

if [ ${copy_packages_to_puppet_modules} = true ]; then
	echo "Copying cartridge agent package to puppet master" | tee -a ${log}
	mkdir -p ${puppet_master_path}/modules/agent/files/
	cp -fv ${stratos_ca_package_path} ${puppet_master_path}/modules/agent/files/
   
	echo "Copying load balancer package to puppet master" | tee -a ${log}
	mkdir -p ${puppet_master_path}/modules/lb/files/
	cp -fv ${stratos_lb_package_path} ${puppet_master_path}/modules/lb/files/
fi

if [ ${copy_jdk_to_puppet_modules} = true ]; then
	echo "Copying jdk package to java puppet module" | tee -a ${log}
	mkdir -p /etc/puppet/modules/java/files/
	cp /opt/${jdk_tar_file} /etc/puppet/modules/java/files/
fi

if [ ${update_nodes_pp_file} = true ]; then
	echo "Updating nodes.pp file" | tee -a ${log}
	cp templates/nodes.pp ${nodes_pp_path}
	sed -i "s@_HOST_IP_@${host_private_ip}@g" ${nodes_pp_path}
	sed -i "s@_JDK_TAR_FILE_@${jdk_tar_file}@g" ${nodes_pp_path}
	sed -i "s@_JDK_FOLDER_@${jdk_folder}@g" ${nodes_pp_path}
fi

if [ ${prepare_installer} = true ]; then
	echo "Preparing stratos installer" | tee -a ${log}
	pushd ${stratos_source_path}
	cp -r ${stratos_source_path}/tools/stratos-installer ${stratos_installer_path}
	popd
	
	echo "Updating stratos installer configuration" | tee -a ${log}
	cp templates/setup.conf ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_STRATOS_INSTALLER_PATH_@${stratos_installer_path}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_STRATOS_PACKAGES_PATH_@${stratos_packages_path}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_STRATOS_PATH_@${stratos_path}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_JAVA_HOME_@${java_home}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_HOST_USER_@${host_user}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_STRATOS_DOMAIN_@${stratos_domain_name}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_HOST_PRIVATE_IP_@${host_private_ip}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_PUPPET_HOSTNAME_@${puppet_hostname}@g" ${stratos_installer_path}/conf/setup.conf
	
	sed -i "s@_MYSQL_HOST_@${mysql_host}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_MYSQL_USERNAME_@${mysql_username}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_MYSQL_PASSWORD_@${mysql_password}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_MYSQL_CONNECTOR_@${mysql_connector_java}@g" ${stratos_installer_path}/conf/setup.conf
	
	sed -i "s@_EC2_IDENTITY_@${ec2_identity}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_EC2_CREDENTIAL_@${ec2_credential}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_EC2_KEYPAIR_NAME_@${ec2_keypair_name}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_EC2_OWNER_ID_@${ec2_owner_id}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_EC2_AVAILABILITY_ZONE_@${ec2_availability_zone}@g" ${stratos_installer_path}/conf/setup.conf
	sed -i "s@_EC2_SECURITY_GROUPS_@${ec2_security_groups}@g" ${stratos_installer_path}/conf/setup.conf
fi

if [ ${start_installer} = true ]; then
	echo "Starting stratos installer" | tee -a ${log}
	mkdir -p ${stratos_path}
	pushd ${stratos_installer_path}
	./setup.sh
	popd
fi