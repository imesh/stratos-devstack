#!/bin/bash

set -e # terminate on any error

home_path="/home/ubuntu"
stratos_version=4.0.0-rc4
stratos_dist_path=https://dist.apache.org/repos/dist/dev/stratos/${stratos_version}
stratos_packages_path=${home_path}"/stratos-packages"
stratos_source_path=${home_path}"/stratos-source"
stratos_installer_path=${home_path}"/stratos-installer"
puppet_installer_path=${home_path}"/puppet-installer"
puppet_master_path=/etc/puppet
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

host_private_ip=10.9.178.167

jdk_tar_file="jdk-7u55-linux-x64.tar.gz"
jdk_folder=jdk1.7.0_55
jdk_download_url="http://download.oracle.com/otn-pub/java/jdk/7u55-b13/${jdk_tar_file}"

activemq_tar_file="apache-activemq-5.9.1-bin.tar.gz"
activemq_download_url="http://apache.spinellicreations.com/activemq/5.9.1/apache-activemq-5.9.1-bin.tar.gz"
activemq_lib_path=${stratos_packages_path}/"apache-activemq-5.9.1/lib"
activemq_lib_required="activemq-broker-5.9.1.jar activemq-client-5.9.1.jar geronimo-j2ee-management_1.1_spec-1.0.1.jar geronimo-jms_1.1_spec-1.1.1.jar hawtbuf-1.9.jar"

install_jdk=true
install_mysql_server=true
install_zip=true
download_stratos_packs=true
download_activemq_pack=true
install_puppet_master=true
copy_puppet_scripts=true
copy_activemq_client_libs=true
copy_packages_to_puppet_modules=true
copy_jdk_to_puppet_modules=true
update_nodes_pp_file=true

mysql_root_password=mysql

log=install.log

if [ ${install_jdk} = true ]; then
   pushd /opt
   echo "Downloading jdk" | tee -a ${log}
   wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" ${jdk_download_url}

   echo "Extracting jdk" | tee -a ${log}
   tar -zxvf ${jdk_tar_file}

   echo "Updating .bashrc" | tee -a ${log}
   echo "" >> ${home_path}/.bashrc
   echo "JAVA_HOME=/opt/jdk1.7.0_55" >> ${home_path}/.bashrc
   echo "PATH=$PATH:$JAVA_HOME/bin" >> ${home_path}/.bashrc
   echo "export JAVA_HOME" >> ${home_path}/.bashrc
   popd
fi

if [ ${install_mysql_server} = true ]; then
   echo "Installing MySQL server" | tee -a ${log}
   debconf-set-selections <<< 'mysql-server mysql-server/root_password password ${mysql_root_password}'
   debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password ${mysql_root_password}'
   apt-get -y install mysql-server
fi

if [ ${install_zip} = true ]; then
   echo "Installing zip" | tee -a ${log}
   apt-get -y install zip
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
	pushd ${stratos_packages_path}
	wget ${activemq_download_url}
	popd
fi

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

if [ ${install_puppet_master} = true ]; then
   echo "Installing puppet master" | tee -a ${log}
   pushd ${puppet_installer_path}
   git clone https://github.com/thilinapiy/puppetinstall .
   ./puppetinstall -m -d stratos.org -s ${host_private_ip}
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
