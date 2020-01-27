# k8s-auto
Basic script to start k8s 3 master nodes HA cluster

## Installation

`git clone git@github.com:SaketSrivastav/k8s-auto.git`

## Setup

### Install the dependencies

```bash
cd k8s-auto
init.sh
```
### Setup Cluster
```bash
cd k8s-auto
./setup_k8s.sh <name> <3 octets of subnet>
Ex: ./setup_k8s.sh kafka "10.10.1"
```

### Cleanup cluster

```bash
pushd k8s-cluster/<name>
vagrant destroy -f
popd

rm -rf kubespray/inventory/<name>
rm -rf k8s-cluster/<name>
```