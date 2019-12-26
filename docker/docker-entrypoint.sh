#!/bin/bash

SFTP_MAIN_GROUP=sftp_group

echo "Running entrypoint"

function create_group() {
    gid="$1"
    group="$2"
    if [ -n "$gid" ]; then
        if ! getent group "$gid" > /dev/null; then
            groupadd --gid "$gid" "$group"
        fi
    fi    
}

# Create Users
function create_user() {
    user="$1"
    pass="$2"
    uid="$3" 
    gid="$4"
    group="$5"

    if [ `id -u $user 2>/dev/null || echo -1` -eq -1 ] ; then
        create_group $gid $group
        mkdir -p "/home/$user"
        useraddOptions+=(--non-unique --uid "$uid" --gid "$gid")
        useradd "${useraddOptions[@]}" "$user"        
        chown $user:$SFTP_MAIN_GROUP "/home/$user"
        chmod 0755 "/home/$user"
        if [ -n "$pass" ]; then            
            echo "$user:$pass" | chpasswd $chpasswdOptions
        else
            usermod -p "*" "$user" # disabled password
            echo "No password set to user $user";
        fi
    fi    
}

function create_directory() {
    user=$1
    group=$2
    directory=$3

    mkdir -p $directory &&
    chmod 0755 $directory &&
    chown $user:$group $directory
}

# To remove warning about mailbox
if [ ! -d "/var/mail" ]; then
    mkdir /var/mail
fi

function copyKey() {
    user=$1
    group=$2
    key_file=$3

    mkdir -p /home/$user/.ssh    
    chown $user:$group /home/$user/.ssh
    chmod 0700 /home/$user/.ssh
    touch /home/$user/.ssh/authorized_keys
    chmod 0600 /home/$user/.ssh/authorized_keys

    cat /tmp/public/$key_file >> /home/$user/.ssh/authorized_keys
    
    chown $user:$group /home/$user/.ssh/authorized_keys
}

function moveKey() {    
    user=$1
    group=$2
    key_file=$3
    copyKey $user $group $key_file
    rm /tmp/public/$key_file
}

create_server_keys() {
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key
}

# user password uid gid groupname
create_user sftp-admin "123456" 1000 1000 $SFTP_MAIN_GROUP
create_server_keys

logger "Executing sshd"
exec /usr/sbin/sshd -D -e

# If you want full debut but it will die once disconnected
# exec /usr/sbin/sshd -D -e -ddd
