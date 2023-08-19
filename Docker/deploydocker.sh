#!/bin/bash
# set -x

[ -z "$USER" ] && export USER=$(id -u -n) && echo "$USER"
dependencies=( 'apt-transport-https' 'ca-certificates' 'curl' 'gnupg-agent' 'software-properties-common' )
packages=( 'containerd.io' 'unzip' 'docker-ce' 'docker-ce-cli' )
declare -a pkg_list 
declare -a dep_list
# pkg_list=()
groupname="docker"

# Check if this script is being invoked with sudo command.
if [[ $EUID -eq 0 ]]; then
    echo -e "\nPlease run this script without sudo\n"
    echo -e "Eg: $0 \n"
    exit 1
fi

# Check if docker.io is installed. if its installed, uninstall it. its outdated. latest package is containerd.io
is_dockerio_installed=$(dpkg-query -W -f='${db:Status-Status}\n' docker.io | grep "installed")
if [ "${is_dockerio_installed}" == "installed" ]; then
  echo ' Removing docker.io'
        sudo apt remove docker.io
fi

# check if necessary docker packages and unzip command are installed.
for pkg in ${packages[@]}; do
    is_pkg_installed=$(dpkg-query -W -f='${db:Status-Status}\n' ${pkg} | grep "installed")
    if [ "${is_pkg_installed}" == "installed" ]; then
        echo ${pkg} is installed.
    else
        pkg_list+=("$pkg")
    fi
done

# if containerd.io is not installed, check if required dependencies are installed, if not, install them and then install containerd.io
if [ ${#pkg_list[@]} -ne 0 ]; then
  # echo "${pkg_list[*]} not installed."
  # echo "${pkg_list[@]} not installed."
  read -e -p "${pkg_list[*]} not installed. Do you want to install it? (y/n): " REPLY
  if [[ $REPLY =~ [Yy] ]]; then
    echo -e "\n Installing '${pkg_list[*]}'."
    if [[ " ${pkg_list[@]} " =~ " containerd.io " ]]; then
      echo -e "Checking if dependencies for containerd.io are installed."
      for dep in "${dependencies[@]}"; do
        is_dependency_installed=$(dpkg-query -W -f='${db:Status-Status}\n' ${dep} | grep "installed")
        if [ "${is_dependency_installed}" == "installed" ]; then
          echo ${dep} is installed.
        else

          dep_list+=("$dep")
          sudo apt install "${dep}" -y
        fi
      done
      if [ ${#dep_list[@]} -ne 0 ]; then
        echo -e "\n Installing unmet dependencies '${dep_list[*]}'."
        sudo apt install "${dep_list[@]}" -y
      fi
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
      sudo apt update
      sudo apt install "${pkg_list[@]}" -y
    else
      sudo apt install "${pkg_list[@]}" -y
    fi
  else
    echo -e "You have not agreed to install the required packages through this script. Please install them manually or run this script again."
    echo -e "If containerd.io is not installed, Required dependencies to install containerd.io are ${dependencies[@]}."
    echo -e "Required packages to be installed are ${pkg_list[@]}. \n Exiting"
    exit 1
  fi
else
  echo -e "All required packages Installed. Checking if user: $USER is a part of group: $groupname . "
fi

# if current user does not have docker as subgroup, create docker group, if it doesn't exist, and add user to group, also update .docker directory ownership to current user.
# echo -e "Adding $USER to $groupname group if user is not a part of it."
is_subgroup=$(id -nGz "$USER" | tr '\0' '\n' | grep '^docker$')
if [ "${is_subgroup}" != "$groupname" ]; then
  echo -e "Adding $USER to $groupname group."
  sudo groupadd -f $groupname && sudo usermod -aG $groupname $USER
  if [ -d "/home/"$USER"/.docker" ]; then
    sudo chown -R "$USER":"$USER" /home/"$USER"/.docker 
  fi
  echo -e "Going to run command \e[1;31m newgrp $groupname \e[0m. \nThis will stop all currently running processes on this terminal to reinitialize the environment.\nPlease run $0 again to set up docker image."
  newgrp $groupname
  echo" Please Run the command: \e[1;31m newgrp $groupname \e[0m, in any new terminal opened if using docker commands until next restart."
fi


# Fetching jaldeetdd.tar.zip file
size=$(wget https://s3.ap-south-1.amazonaws.com/nv.s3.bucket.mumbai/jaldeetdd.tar.zip --spider 2>&1 | grep "Length" | awk '{print $3}' | tr -d '()')
read -e -p " The docker image zip file, jaldeetdd.tar.zip, is of size ${size}. Would you like to download it now? (y/n) " ans
if [[ $ans =~ [Yy] ]]; then
  # If jaldeetdd.tar file exists in current location, delete it.
  if [ -f "jaldeetdd.tar" ]; then 
    rm jaldeetdd.tar
  fi

  # If jaldeetdd.tar.zip file exists in current location, delete it.
  if [ -f "jaldeetdd.tar.zip" ]
  then   
    rm jaldeetdd.tar.zip
  fi
  echo "Downloading Docker image zip file."
  wget 'https://s3.ap-south-1.amazonaws.com/nv.s3.bucket.mumbai/jaldeetdd.tar.zip'
  
  echo "Extracting and Deploying Docker image."
  unzip -o jaldeetdd.tar.zip
  docker load < "jaldeetdd.tar"
  echo "Cleaning up. Deleting jaldeetdd.tar.zip"
  if [ -f "jaldeetdd.tar.zip" ]
  then   
    rm jaldeetdd.tar.zip
  fi
  echo "Cleaning up. Deleting jaldeetdd.tar"
  if [ -f "jaldeetdd.tar" ]
  then   
    rm jaldeetdd.tar
  fi
else
  echo -e "You may run this script again whenever you are ready to download the file."
  echo -e "If you decide to fetch the file manually outside of this script, you may run the following commands to Extract and deploy it."
  echo -e "unzip -o jaldeetdd.tar.zip"
  echo -e 'docker load < "jaldeetdd.tar"'
  echo -e "Exiting."
  exit 2
fi


  
  
