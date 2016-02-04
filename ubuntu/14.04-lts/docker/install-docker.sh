#!/bin/bash -e

: ${KERNEL_VERSION:="$(uname -r)"}
: ${GPG_KEY:="58118E89F3A912897C070ADBF76221572C52609D"}
: ${GPG_KEY_SERVER:="hkp://p80.pool.sks-keyservers.net:80"}
: ${DEBIAN_REPOSITORY__DOCKER:="deb https://apt.dockerproject.org/repo ubuntu-trusty main"}

#------------------------------------------------------------------------------
# Check: Kernel >= 3.10
#------------------------------------------------------------------------------
if test -z "${KERNEL_VERSION}"; then
  echo "[FATAL] Unable to compute your kernel's version number. Kernel must be >= 3.10."
  exit 1
else
  echo "[INFO] KERNEL_VERSION='${KERNEL_VERSION}'"
fi

if ! kernel_major_version="$(echo ${KERNEL_VERSION} | awk 'BEGIN { FS="." } { print $1 }')" || \
    test -z "${kernel_major_version}"
then
  echo "[FATAL] Unable to compute your kernel's major version number. Kernel must be >= 3.10."
  exit 1
else
  echo "[INFO] kernel_major_version='${kernel_major_version}'"
fi

if ! kernel_minor_version="$(echo ${KERNEL_VERSION} | awk 'BEGIN { FS="." } { print $2 }')" || \
    test -z "${kernel_minor_version}"
then
  echo "[FATAL] Unable to compute your kernel's minor version number. Kernel must be >= 3.10."
  exit 1
else
  echo "[INFO] kernel_minor_version='${kernel_minor_version}'"
fi

#------------------------------------------------------------------------------
# Add gpg key for Docker
#------------------------------------------------------------------------------
if ! gpg_output=$(sudo apt-key adv --keyserver "${GPG_KEY_SERVER}" --recv-keys "${GPG_KEY}"); then
  echo "[FATAL] Unable to add gpg key for Docker"
  exit 1
else
  echo "[INFO] Successfully added Docker's GPG Key"
fi

#------------------------------------------------------------------------------
# Add Docker's Debian Ubuntu Trusty 14.04 (LTS) repository
#------------------------------------------------------------------------------
echo "[INFO] Adding Docker's Debian repository to '/etc/apt/sources.list.d/docker.list'"
sudo touch /etc/apt/sources.list.d/docker.list

sudo chown ubuntu:ubuntu /etc/apt/sources.list.d/docker.list

# Remove existing entries in docker.list
sudo cat > /etc/apt/sources.list.d/docker.list <<EOF
${DEBIAN_REPOSITORY__DOCKER}
EOF

sudo apt-get update
sudo apt-cache policy docker-engine
sudo apt-get install --yes "linux-image-extra-${KERNEL_VERSION}"

#------------------------------------------------------------------------------
# Install Docker
#------------------------------------------------------------------------------
sudo apt-get install --yes docker-engine
sudo gpasswd -a ${USER} docker

cat <<EOF
-------------------------------------------------------------------------------
[INFO] Successfully installed Docker!

Please \`logout\` and re-login to be added to the docker unix group.

Once logged in, test docker:

    $ docker run hello-world

Complete.
-------------------------------------------------------------------------------
EOF

