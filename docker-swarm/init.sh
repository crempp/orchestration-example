#!/usr/bin/env bash

function get_ssh_version {
    # ssh -V prints to stderr, redirect
    ssh_ver=$(ssh -V 2>&1)
    [[ -n $ZSH_VERSION ]] && setopt LOCAL_OPTIONS KSH_ARRAYS BASH_REMATCH
    [[ $ssh_ver =~ OpenSSH_([0-9][.][0-9]) ]] && echo "${BASH_REMATCH[1]}"
}

if [ ! -f terraform.tfvars ]; then
    echo "Enter your DigitalOcean deployment token:"
    read deployment_do_token

    echo "Enter your DigitalOcean readonly token:"
    read readonly_do_token

    echo "Enter the path to your public key [~/.ssh/id_rsa.pub]:"
    read pub_key
    if [[  -z  $pub_key  ]]; then
        pub_key=~/.ssh/id_rsa.pub
    fi

    echo "Enter the path to your private key [~/.ssh/id_rsa]:"
    read pvt_key
    if [[  -z  $pvt_key  ]]; then
        pvt_key=~/.ssh/id_rsa
    fi

    echo "Enter the number of nodes for the swarm [2]:"
    read node_count
    if [[  -z  $node_count  ]]; then
        node_count=2
    fi

    echo "Enter the DigitalOcean region [sfo1]:"
    read region
    if [[  -z  $region  ]]; then
        region="sfo1"
    fi

    echo "Enter the size of the Droplets (master and nodes) [512mb]:"
    read size
    if [[  -z  $size  ]]; then
        size="512mb"
    fi

    # if ssh version is under 6.9, use -lf, otherwise must use the -E version
    if ! awk -v ver="$(get_ssh_version)" 'BEGIN { if (ver < 6.9) exit 1; }'; then
        ssh_fingerprint=$(ssh-keygen -lf $pub_key | awk '{print $2}')
    else
        ssh_fingerprint=$(ssh-keygen -E MD5 -lf $pub_key | awk '{print $2}' | sed 's/MD5://g')
    fi

    cat << EOF > terraform.tfvars
deployment_do_token = "$deployment_do_token"
readonly_do_token = "$readonly_do_token"
pub_key = "$pub_key"
pvt_key = "$pvt_key"
ssh_fingerprint = "$ssh_fingerprint"
node_count = "$node_count"
region = "$region"
size = "$size"
EOF

fi
