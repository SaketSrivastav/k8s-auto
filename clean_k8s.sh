#!/bin/bash

if test "$#" -ne 1; then
    echo "$1 cluster not found"
    echo "usage: sudo ./cleanup_k8s.sh <name-prefix>"
    exit 1
fi

name=$1
echo "==> Cluster $name cleanup start"

# Cleanup k8s-cluster
if [[ -d k8s-cluster/$name ]]; then
    echo "==> Shutting down vagrant vms"
    pushd k8s-cluster/$name
    vagrant destroy -f
    sudo rm -rf /var/lib/libvirt/images/$name*
    rm -rf k8s-cluster/$name
    popd
else
    echo "==> Skip k8s-cluster removal"
fi

# Cleanup kubespray
if [ -d kubespray/inventory/$name ]; then
    echo "==> Removing kubespray configs"
    rm -rf kubespray/inventory/$name
else
    echo "==> Skip kubespray config removal"
fi

echo "==> Cluster $name cleanup done"