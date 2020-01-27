if test "$#" -ne 1; then
    echo "$1 cluster not found"
    echo "usage: sudo ./cleanup_k8s.sh <name-prefix>"
    exit 1
fi

name=$1

# Cleanup k8s-cluster
if ! [[ -d k8s-cluster/$name ]]; then
    echo "$name cluster not found"
    exit 1
fi

pushd k8s-cluster/<name>
vagrant destroy -f
popd
rm -rf k8s-cluster/<name>

# Cleanup kubespray
if ! [[ -d kubespray/inventory/$name ]]; then
    echo "$name cluster not found"
    exit 1
fi


rm -rf kubespray/inventory/<name>