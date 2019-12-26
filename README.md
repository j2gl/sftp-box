# sftp-box

This is a Docker container for an sftp.

# Usage

## For the impatient:
```sh
make all

make container 
# pass 123456
```

Connect to server.
```sh
sftp -P 10022 sftp-admin@localhost
```
Password: `123456`

## Build image

```sh
docker build -t sftp-box:1.0 .
```

```sh
docker run -d -p 10022:22 sftp-box:1.0 --name sftp-box
```

## Server Keys

Keys are inside this folder: `docker/keys`.  

The key was generated like this:
```sh
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key
```

## Client Keys

Example to generate a client key
```sh
ssh-keygen -t rsa -b 1024 -C "wells" -f ./keys/public/wells_test_key
mv ./keys/public/wells_test_key ./keys/private
```

Verify Key
```sh
ssh-keygen -y -f ./keys/private/wells_test_key
```

# References

* [atmox/sftp](https://github.com/atmoz/sftp)
* Some information about [SSH keys](https://stribika.github.io/2015/01/04/secure-secure-shell.html)
