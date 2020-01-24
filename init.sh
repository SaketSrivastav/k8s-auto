#! /bin/bash

# Setup core tools
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root, use sudo "$0" instead" 1>&2
    exit 1
fi

apt update
apt install -y python python-pip vim curl

# Install libvirt and kvm
apt install -y libvirt-bin qemu qemu-kvm libvirt-dev
modprobe kvm kvm-intel
adduser $USER libvirt
systemctl enable libvirtd
systemctl restart libvirtd

default_pool=$("virsh pool-list --name | grep default")
if [[ -z $default_pool ]]; then
    virsh pool-define /dev/stdin <<EOF
      <pool type='dir'>
        <name>default</name>
        <target>
          <path>/var/lib/libvirt/images</path>
        </target>
      </pool>
EOF
    virsh pool-start default
    virsh pool-autostart default
fi

# Install Vagrant and vagrant libvirt plugin
adduser $USER vagrant

is_vagrant_plugin_installed=$("vagrant plugin list | grep -o libvirt")
if [[ -z $is_vagrant_plugin_installed ]]; then
    vagrant plugin install vagrant-libvirt
fi

# Setup ssh keys for passwordless login to cluster
if [ -f $HOME/.ssh/id_rsa ]; then
    ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa
fi

# Setup kubespray
git submodule update --init
cd kubespray
pip install -r requirements.txt

# Cluster vm directory
mkdir k8s-clusters