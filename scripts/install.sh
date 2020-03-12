#!/bin/bash
[[ -z $* ]] && { echo "Please specify a Public IP or Host/Domain name." && exit 1; }
# Fetch and Install
file_url="$(curl -sL https://github.com/openshift/origin/releases/latest | grep "download.*client.*linux-64" | cut -f2 -d\" | sed 's/^/https:\/\/github.com/')"
[[ -z $file_url ]] && { echo "The URL could not be obtained.  Please try again shortly." && exit 1; }
file_name="$(echo $file_url | cut -f9 -d/)"
if [[ ! -f $file_name ]]; then
        curl -sL $file_url --output $file_name
        folder_name="$(tar ztf $file_name 2>/dev/null | head -1 | sed s:/.*::)"
        [[ -z $folder_name ]] && { echo "The archive could not be read.  Please try again." && rm -f $file_name && exit 1; }
        tar zxf $file_name
        mv $folder_name/oc $folder_name/kubectl $HOME/.local/bin && rm -r $folder_name
        chmod 754 $HOME/.local/bin/oc $HOME/.local/bin/kubectl
fi
# Docker insecure
[[ $(grep insecure /etc/docker/daemon.json &>/dev/null; echo $?) -eq 2 ]] && redirect=">"
[[ $(grep insecure /etc/docker/daemon.json &>/dev/null; echo $?) -eq 1 ]] && redirect=">>"
[[ $(grep insecure /etc/docker/daemon.json &>/dev/null; echo $?) -eq 0 ]] || { sudo bash -c "cat << 'EOF' $redirect /etc/docker/daemon.json
{
        \"insecure-registries\" : [ \"172.30.0.0/16\" ]
}
EOF" && sudo systemctl restart docker; }
# OpenShift Origin up
[[ ! -d $HOME/.local/etc/openshift ]] && { mkdir -p $HOME/.local/etc/openshift && cd $HOME/.local/etc/openshift; } || { cd $HOME/.local/etc/openshift && oc cluster down; }
oc cluster up --public-hostname=$1

exit 0
