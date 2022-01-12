#!/bin/bash

echo "Setting up Rsyslog Configuration"
sudo mkdir -p /etc/systemd/system/rsyslog.service.d/
{ echo "[Service]"; 
  echo "Environment=\"LOGSTASH_IP=${logstash_ip}\"";
  echo "Environment=\"HYDROVIS_APPLICATION=replace_route\"";
} | sudo tee /etc/systemd/system/rsyslog.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl restart rsyslog


echo "Setting up RNR Mount"
cd
sudo mkdir /rnr
sudo file -s /dev/sdf
sudo lsblk -f
sudo mkfs -t xfs /dev/sdf
sudo mount /dev/sdf /rnr
#--------------------------------------------------
#change the /etc/fstab file to make sure the volume mounts after a reboot
#extract the UUID to be included in the /etc/fstab line
block_output=`sudo blkid | grep xfs | grep -v LABEL`
# output example from block_output
#/dev/nvme1n1: UUID="bb4ee817-111a-4cb6-b540-a40c1d34a8fa" TYPE="xfs"
uuid_part=`echo $block_output | cut -d ' ' -f2 | sed 's/\"//g'`
#Example fstab line to add to the end:
#UUID=bb4ee817-111a-4cb6-b540-a40c1d34a8fa     /rnr        xfs    defaults,nofail   0   2
export line_to_add="$uuid_part        /rnr    xfs     defaults,nofail        0       2"
echo $line_to_add >> "/etc/fstab"

#-----------------------------------------------------

echo "Installing System Dependencies"
sudo amazon-linux-extras install epel -y
sudo yum-config-manager --enable epel
sudo yum -y install git python3-devel openmpi-devel hdf5-devel  gcc-c++ cmake3 curl-devel make
sudo yum -y install m4

echo "Installing Python Dependencies"
sudo git clone https://github.com/Unidata/netcdf-c.git /opt/netcdf-c
cd /opt/netcdf-c
sudo cmake3 .
sudo make install
sudo git clone https://github.com/Unidata/netcdf-fortran.git /opt/netcdf-fortran
cd /opt/netcdf-fortran
sudo cmake3 .
sudo make install

echo "Updating Permissions"
cd
sudo chown ssm-user: /rnr

echo "Installing WRF-Hydro Files"
cd /rnr
aws s3 cp s3://${DEPLOYMENT_DATA_BUCKET}/rnr/wrf_hydro.tgz .
tar -zxvf wrf_hydro.tgz

echo "Installing Replace and Route"
cd /rnr
sudo aws s3 cp s3://${DEPLOYMENT_DATA_BUCKET}/rnr/owp-viz-replace-route.tgz .
tar -zxvf owp-viz-replace-route.tgz
#git clone https://vlab.ncep.noaa.gov/code-review/a/owp-viz-replace-route

echo "Installing RNR Dependencies"
cd /rnr/owp-viz-replace-route
#sudo git checkout python-timeslicegen
bash install.sh -s

echo "Copying Static Resources"
cd /rnr
sudo aws s3 cp  s3://${DEPLOYMENT_DATA_BUCKET}/rnr/rnr_static.tgz  .
tar -zxvf rnr_static.tgz
sudo chown root static
sudo chgrp root static
sudo mkdir /rnr/owp-viz-replace-route/RESOURCES
sudo cp -r static /rnr/owp-viz-replace-route/RESOURCES/
sudo rm rnr_static.tgz

echo "Updating Libnetcdf Link"
#Make sure that libnetcdf.so is available to the wrf_hydro executable, which is expecting libnetcdf.so.18
#Note: version 18 will point to the generic name which already points to a different specific name, such as libnetcdf.so.19.
cd /usr/local/lib64
sudo ln -s libnetcdf.so libnetcdf.so.18

echo "Setting up RNR File Structure"
sudo mkdir /rnr/share
sudo mkdir /rnr/share/log
sudo mkdir /rnr/share/.archive
sudo mkdir /rnr/share/Run

echo "Copying Rendered Template File to Replace and Route"
sudo cp /deploy_files/conus.ini /rnr/owp-viz-replace-route/configs/conus.ini
sudo cp /deploy_files/.env.devel /rnr/owp-viz-replace-route/.env.devel

echo "Setting up RNR Crontab"
sudo crontab -l -u ec2-user > /tmp/mycrontab
echo '10 * * * * cd /rnr/owp-viz-replace-route && sudo ./run.sh' >> /tmp/mycrontab
sudo crontab -u ec2-user /tmp/mycrontab

echo "Finished Setup"
