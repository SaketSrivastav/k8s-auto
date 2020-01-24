if test "$#" -ne 4; then
    echo "Illegal number of arguments: $#"
    echo "usage: sudo ./setup_k8s.sh <name-prefix> <subnet>"
    exit 1
fi

if ! [ -x "$(hash vagrant 2>/dev/null)" ];
then
  echo "ERROR: vagrant is not installed, please run init.sh"
  exit 1
fi

if ! [ -x "$(hash virsh 2>/dev/null)" ];
then
  echo "ERROR: livbirt is not installed, please run init.sh"
  exit 1
fi

name=$1
node_subnet=$2

echo "INFO: Setup k8s-cluster with nodename prefix: $1 and subnet: $2"
cluster_dir=k8s-cluster/$name
mkdir -p $cluster_dir

cp Vagrantfile $cluster_dir
sed -i "s/\$instance_name_prefix= \"k8s\"/\$instance_name_prefix= \"$name\"/g" Vagrantfile
sed -i "s/\$subnet = \"\"/\$subnet = \"$node_subnet\"/g" Vagrantfile

# vagrant up
vagrant up --provider=libvirt


inv_name="inventory/$name"
cp -rfp inventory/sample $inv_name
CONFIG_FILE=$inv_name/hosts.yaml \
KUBE_MASTERS_MASTERS=3 HOST_PREFIX=$name \
python3 contrib/inventory_builder/inventory.py \
  $node_subnet.101 $node_subnet.102 $node_subnet.103 
sed -i "s/access/#access/g" $inv_name/hosts.yaml

ansible-playbook -b -v -u root -i $inv_name/hosts.yaml cluster.yml