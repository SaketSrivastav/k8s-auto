if test "$#" -ne 2; then
    echo "Illegal number of arguments: $#"
    echo "usage: sudo ./setup_k8s.sh <name-prefix> <subnet>"
    exit 1
fi

if ! [ -x $(hash vagrant 2>/dev/null) ];
then
    echo "ERROR: vagrant is not installed, please run init.sh"
    exit 1
fi

if ! [ -x $(hash vboxmanage 2>/dev/null) ];
then
    if ! [ -x $(hash virsh 2>/dev/null) ];
    then
        echo "ERROR: livbirt is not installed, please run init.sh"
        exit 1
    fi
fi

# Setup ssh keys for passwordless login to cluster
if ! [ -f $HOME/.ssh/id_rsa ]; then
    ssh-keygen -q -t rsa -N '' -f $HOME/.ssh/id_rsa
fi

name=$1
node_subnet=$2

echo "INFO: Setup k8s-cluster with nodename prefix: $1 and subnet: $2"
cluster_dir=k8s-cluster/$name
mkdir -p $cluster_dir
cp Vagrantfile_template $cluster_dir/Vagrantfile

pushd $cluster_dir 2> /dev/null
sed -i "s/\$instance_name_prefix = \"k8s\"/\$instance_name_prefix = \"$name\"/g" Vagrantfile
sed -i "s/\$subnet = \"\"/\$subnet = \"$node_subnet\"/g" Vagrantfile

# vagrant up
if ! [ -x $(hash vboxmanage 2>/dev/null) ];
then
  vagrant up --provider=libvirt
else
  vagrant up
fi

popd 2> /dev/null

pushd kubespray
inv_name="inventory/$name"
cp -rfp inventory/sample $inv_name
CONFIG_FILE=$inv_name/hosts.yaml \
KUBE_MASTERS_MASTERS=3 HOST_PREFIX=$name \
python3 contrib/inventory_builder/inventory.py \
$node_subnet.101 $node_subnet.102 $node_subnet.103
sed -i "s/access/#access/g" $inv_name/hosts.yaml

ansible-playbook -b -v -u root -i $inv_name/hosts.yaml cluster.yml
popd 2> /dev/null

