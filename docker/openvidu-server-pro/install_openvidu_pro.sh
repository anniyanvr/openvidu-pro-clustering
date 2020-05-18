#!/usr/bin/env bash

# Global variables
OPENVIDU_FOLDER=openvidu
OPENVIDU_VERSION=master
AWS_SCRIPTS_FOLDER=${OPENVIDU_FOLDER}/cluster/aws
ELASTICSEARCH_FOLDER=${OPENVIDU_FOLDER}/elasticsearch

fatal_error() {
    printf "\n     =======¡ERROR!======="
    printf "\n     %s" "$1"
    printf "\n"
    exit 0
}

new_ov_installation() {
     printf '\n'
     printf '\n     ======================================='
     printf '\n          Install Openvidu PRO %s' "${OPENVIDU_VERSION}"
     printf '\n     ======================================='
     printf '\n'

     # Create folder openvidu-docker-compose
     printf '\n     => Creating folder '%s'...' "${OPENVIDU_FOLDER}"
     mkdir "${OPENVIDU_FOLDER}" || fatal_error "Error while creating the folder '${OPENVIDU_FOLDER}'"

     # Create aws scripts folder
     printf "\n     => Creating folder 'cluster/aws'..."
     mkdir -p "${AWS_SCRIPTS_FOLDER}" || fatal_error "Error while creating the folder 'cluster/aws'"

     # Create elasticsearch folder
     printf "\n     => Creating folder 'elasticsearch'..."
     mkdir -p "${ELASTICSEARCH_FOLDER}" || fatal_error "Error while creating the folder 'elasticsearch'"

     printf "\n     => Changing permission to 'elasticsearch' folder..."
     chown 1000:1000 "${ELASTICSEARCH_FOLDER}" || fatal_error "Error while changing permission to 'elasticsearch' folder"

     # Download necessary files
     printf '\n     => Downloading Openvidu PRO files:'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/cluster/aws/openvidu_autodiscover.sh \
          --output "${AWS_SCRIPTS_FOLDER}/openvidu_autodiscover.sh" || fatal_error "Error when downloading the file 'openvidu_autodiscover.sh'"
     printf '\n          - openvidu_autodiscover.sh'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/cluster/aws/openvidu_drop.sh \
          --output "${AWS_SCRIPTS_FOLDER}/openvidu_drop.sh" || fatal_error "Error when downloading the file 'openvidu_drop.sh'"
     printf '\n          - openvidu_drop.sh'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/cluster/aws/openvidu_launch_kms.sh \
          --output "${AWS_SCRIPTS_FOLDER}/openvidu_launch_kms.sh" || fatal_error "Error when downloading the file 'openvidu_launch_kms.sh'"
     printf '\n          - openvidu_launch_kms.sh'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/.env \
          --output "${OPENVIDU_FOLDER}/.env" || fatal_error "Error when downloading the file '.env'"
     printf '\n          - .env'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/docker-compose.override.yml \
          --output "${OPENVIDU_FOLDER}/docker-compose.override.yml" || fatal_error "Error when downloading the file 'docker-compose.override.yml'"
     printf '\n          - docker-compose.override.yml'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/docker-compose.yml \
          --output "${OPENVIDU_FOLDER}/docker-compose.yml" || fatal_error "Error when downloading the file 'docker-compose.yml'"
     printf '\n          - docker-compose.yml'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/openvidu \
          --output "${OPENVIDU_FOLDER}/openvidu" || fatal_error "Error when downloading the file 'openvidu'"
     printf '\n          - openvidu'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/readme.md \
          --output "${OPENVIDU_FOLDER}/readme.md" || fatal_error "Error when downloading the file 'readme.md'"
     printf '\n          - readme.md'

     # Add execution permissions
     printf "\n     => Adding permission:"

     chmod +x "${OPENVIDU_FOLDER}/openvidu" || fatal_error "Error while adding permission to 'openvidu' program"
     printf '\n          - openvidu'

     chmod +x "${AWS_SCRIPTS_FOLDER}/openvidu_autodiscover.sh" || fatal_error "Error while adding permission to 'openvidu_autodiscover.sh' program"
     printf '\n          - openvidu_autodiscover.sh'

     chmod +x "${AWS_SCRIPTS_FOLDER}/openvidu_drop.sh" || fatal_error "Error while adding permission to 'openvidu' openvidu_drop.sh"
     printf '\n          - openvidu_drop.sh'

     chmod +x "${AWS_SCRIPTS_FOLDER}/openvidu_launch_kms.sh" || fatal_error "Error while adding permission to 'openvidu_launch_kms.sh' program"
     printf '\n          - openvidu_launch_kms.sh'

     # Create own certificated folder
     printf "\n     => Creating folder 'owncert'..."
     mkdir "${OPENVIDU_FOLDER}/owncert" || fatal_error "Error while creating the folder 'owncert'"

     # Ready to use
     printf '\n'
     printf '\n'
     printf '\n     ======================================='
     printf '\n       Openvidu PRO successfully installed.'
     printf '\n     ======================================='
     printf '\n'
     printf '\n     1. Go to openvidu folder:'
     printf '\n     $ cd openvidu'
     printf '\n'
     printf '\n     2. Configure OPENVIDU_DOMAIN_OR_PUBLIC_IP, OPENVIDU_PRO_LICENSE, OPENVIDU_SECRET, and KIBANA_PASSWORD in .env file:'
     printf '\n     $ nano .env'
     printf '\n'
     printf '\n     3. Start OpenVidu'
     printf '\n     $ ./openvidu start'
     printf '\n'
     printf "\n     CAUTION: The folder 'openvidu/elasticsearch' use user and group 1000 permissions. This folder is necessary for store elasticsearch data."
     printf '\n     For more information, check readme.md'
     printf '\n'
     printf '\n'
     exit 0
}

upgrade_ov() {
     # Search local Openvidu installation
     printf '\n'
     printf '\n     ============================================'
     printf '\n       Search Previous Installation of Openvidu'
     printf '\n     ============================================'
     printf '\n'

     SEARCH_IN_FOLDERS=(
          "${PWD}"
          "/opt/${OPENVIDU_FOLDER}"
     )

     for folder in "${SEARCH_IN_FOLDERS[@]}"; do
          printf "\n     => Searching in '%s' folder..." "${folder}"

          if [ -f "${folder}/docker-compose.yml" ]; then
               OPENVIDU_PREVIOUS_FOLDER="${folder}"

               printf "\n     => Found installation in folder '%s'" "${folder}"
               break
          fi
     done

     [ -z "${OPENVIDU_PREVIOUS_FOLDER}" ] && fatal_error "No previous Openvidu installation found"

     # Uppgrade Openvidu
     OPENVIDU_PREVIOUS_VERSION=$(grep 'Openvidu Version:' "${OPENVIDU_PREVIOUS_FOLDER}/docker-compose.yml" | awk '{ print $4 }')
     [ -z "${OPENVIDU_PREVIOUS_VERSION}" ] && OPENVIDU_PREVIOUS_VERSION=2.13.0

     # In this point using the variable 'OPENVIDU_PREVIOUS_VERSION' we can verify if the upgrade is
     # posible or not. If it is not posible launch a warning and stop the upgrade.

     printf '\n'
     printf '\n     ======================================='
     printf '\n       Upgrade Openvidu PRO %s to %s' "${OPENVIDU_PREVIOUS_VERSION}" "${OPENVIDU_VERSION}"
     printf '\n     ======================================='
     printf '\n'

     ROLL_BACK_FOLDER="${OPENVIDU_PREVIOUS_FOLDER}/.old-${OPENVIDU_PREVIOUS_VERSION}"
     TMP_FOLDER="${OPENVIDU_PREVIOUS_FOLDER}/tmp"
     ACTUAL_FOLDER="${PWD}"
     USE_OV_CALL=$(grep -E '^        image: openvidu/openvidu-call:.*$' "${OPENVIDU_PREVIOUS_FOLDER}/docker-compose.override.yml" | tr -d '[:space:]')

     printf "\n     Creating rollback folder '%s'..." ".old-${OPENVIDU_PREVIOUS_VERSION}"
     mkdir "${ROLL_BACK_FOLDER}" || fatal_error "Error while creating the folder '.old-${OPENVIDU_PREVIOUS_VERSION}'"

     printf "\n     Creating temporal folder 'tmp'..."
     mkdir "${TMP_FOLDER}" || fatal_error "Error while creating the folder 'temporal'"

     # Download necessary files
     printf '\n     => Downloading new Openvidu PRO files:'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/cluster/aws/openvidu_autodiscover.sh \
          --output "${TMP_FOLDER}/openvidu_autodiscover.sh" || fatal_error "Error when downloading the file 'openvidu_autodiscover.sh'"
     printf '\n          - openvidu_autodiscover.sh'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/cluster/aws/openvidu_drop.sh \
          --output "${TMP_FOLDER}/openvidu_drop.sh" || fatal_error "Error when downloading the file 'openvidu_drop.sh'"
     printf '\n          - openvidu_drop.sh'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/cluster/aws/openvidu_launch_kms.sh \
          --output "${TMP_FOLDER}/openvidu_launch_kms.sh" || fatal_error "Error when downloading the file 'openvidu_launch_kms.sh'"
     printf '\n          - openvidu_launch_kms.sh'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/.env \
          --output "${TMP_FOLDER}/.env" || fatal_error "Error when downloading the file '.env'"
     printf '\n          - .env'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/docker-compose.override.yml \
          --output "${TMP_FOLDER}/docker-compose.override.yml" || fatal_error "Error when downloading the file 'docker-compose.override.yml'"
     printf '\n          - docker-compose.override.yml'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/docker-compose.yml \
          --output "${TMP_FOLDER}/docker-compose.yml" || fatal_error "Error when downloading the file 'docker-compose.yml'"
     printf '\n          - docker-compose.yml'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/openvidu \
          --output "${TMP_FOLDER}/openvidu" || fatal_error "Error when downloading the file 'openvidu'"
     printf '\n          - openvidu'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/readme.md \
          --output "${TMP_FOLDER}/readme.md" || fatal_error "Error when downloading the file 'readme.md'"
     printf '\n          - readme.md'

     # Dowloading new images and stoped actual Openvidu
     printf '\n     => Dowloading new images...'
     printf '\n'
     sleep 1

     printf "\n          => Moving to 'tmp' folder..."
     printf '\n'
     cd "${TMP_FOLDER}" || fatal_error "Error when moving to 'tmp' folder"
     printf '\n'
     docker-compose pull | true

     printf '\n     => Stoping Openvidu...'
     printf '\n'
     sleep 1

     printf "\n          => Moving to 'openvidu' folder..."
     printf '\n'
     cd "${OPENVIDU_PREVIOUS_FOLDER}" || fatal_error "Error when moving to 'openvidu' folder"
     printf '\n'
     docker-compose down | true

     printf '\n'
     printf '\n     => Moving to working dir...'
     cd "${ACTUAL_FOLDER}" || fatal_error "Error when moving to working dir"

     # Move old files to rollback folder
     printf '\n     => Moving previous installation files to rollback folder:'

     mv "${OPENVIDU_PREVIOUS_FOLDER}/docker-compose.yml" "${ROLL_BACK_FOLDER}" || fatal_error "Error while moving previous 'docker-compose.yml'"
     printf '\n          - docker-compose.yml'

     if [ ! -z "${USE_OV_CALL}" ]; then
          mv "${OPENVIDU_PREVIOUS_FOLDER}/docker-compose.override.yml" "${ROLL_BACK_FOLDER}" || fatal_error "Error while moving previous 'docker-compose.override.yml'"
          printf '\n          - docker-compose.override.yml'
     fi

     mv "${OPENVIDU_PREVIOUS_FOLDER}/openvidu" "${ROLL_BACK_FOLDER}" || fatal_error "Error while moving previous 'openvidu'"
     printf '\n          - openvidu'

     mv "${OPENVIDU_PREVIOUS_FOLDER}/readme.md" "${ROLL_BACK_FOLDER}" || fatal_error "Error while moving previous 'readme.md'"
     printf '\n          - readme.md'

     mv "${OPENVIDU_PREVIOUS_FOLDER}/cluster/aws" "${ROLL_BACK_FOLDER}" || fatal_error "Error while moving previous 'cluster/aws'"
     printf '\n          - cluster/aws'

     # Move tmp files to Openvidu
     printf '\n     => Updating files:'

     mv "${TMP_FOLDER}/docker-compose.yml" "${OPENVIDU_PREVIOUS_FOLDER}" || fatal_error "Error while updating 'docker-compose.yml'"
     printf '\n          - docker-compose.yml'

     if [ ! -z "${USE_OV_CALL}" ]; then
          mv "${TMP_FOLDER}/docker-compose.override.yml" "${OPENVIDU_PREVIOUS_FOLDER}" || fatal_error "Error while updating 'docker-compose.override.yml'"
          printf '\n          - docker-compose.override.yml'
     else
          mv "${TMP_FOLDER}/docker-compose.override.yml" "${OPENVIDU_PREVIOUS_FOLDER}/docker-compose.override.yml-${OPENVIDU_VERSION}" || fatal_error "Error while updating 'docker-compose.override.yml'"
          printf '\n          - docker-compose.override.yml-%s' "${OPENVIDU_VERSION}"
     fi

     mv "${TMP_FOLDER}/.env" "${OPENVIDU_PREVIOUS_FOLDER}/.env-${OPENVIDU_VERSION}" || fatal_error "Error while moving previous '.env'"
     printf '\n          - .env-%s' "${OPENVIDU_VERSION}"

     mv "${TMP_FOLDER}/openvidu" "${OPENVIDU_PREVIOUS_FOLDER}" || fatal_error "Error while updating 'openvidu'"
     printf '\n          - openvidu'

     mv "${TMP_FOLDER}/readme.md" "${OPENVIDU_PREVIOUS_FOLDER}" || fatal_error "Error while updating 'readme.md'"
     printf '\n          - readme.md'

     mkdir "${OPENVIDU_PREVIOUS_FOLDER}/cluster/aws" || fatal_error "Error while creating the folder 'cluster/aws'"

     mv "${TMP_FOLDER}/openvidu_autodiscover.sh" "${OPENVIDU_PREVIOUS_FOLDER}/cluster/aws" || fatal_error "Error while updating 'readme.md'"
     printf '\n          - openvidu_autodiscover.sh'

     mv "${TMP_FOLDER}/openvidu_drop.sh" "${OPENVIDU_PREVIOUS_FOLDER}/cluster/aws" || fatal_error "Error while updating 'readme.md'"
     printf '\n          - openvidu_drop.sh'

     mv "${TMP_FOLDER}/openvidu_launch_kms.sh" "${OPENVIDU_PREVIOUS_FOLDER}/cluster/aws" || fatal_error "Error while updating 'readme.md'"
     printf '\n          - openvidu_launch_kms.sh'

     printf "\n     => Deleting 'tmp' folder"
     rm -rf "${TMP_FOLDER}" || fatal_error "Error deleting 'tmp' folder"

     # Add execution permissions
     printf "\n     => Adding permission to 'openvidu' program..."

     chmod +x "${OPENVIDU_PREVIOUS_FOLDER}/openvidu" || fatal_error "Error while adding permission to 'openvidu' program"
     printf '\n          - openvidu'

     chmod +x "${OPENVIDU_PREVIOUS_FOLDER}/cluster/aws/openvidu_autodiscover.sh" || fatal_error "Error while adding permission to 'openvidu_autodiscover.sh' program"
     printf '\n          - openvidu_autodiscover.sh'

     chmod +x "${OPENVIDU_PREVIOUS_FOLDER}/cluster/aws/openvidu_drop.sh" || fatal_error "Error while adding permission to 'openvidu' openvidu_drop.sh"
     printf '\n          - openvidu_drop.sh'

     chmod +x "${OPENVIDU_PREVIOUS_FOLDER}/cluster/aws/openvidu_launch_kms.sh" || fatal_error "Error while adding permission to 'openvidu_launch_kms.sh' program"
     printf '\n          - openvidu_launch_kms.sh'

     # Ready to use
     printf '\n'
     printf '\n'
     printf '\n     ================================================'
     printf "\n     Openvidu successfully upgraded to version %s" "${OPENVIDU_VERSION}"
     printf '\n     ================================================'
     printf '\n'
     printf "\n     1. A new file 'docker-compose.yml' has been created with the new OpenVidu %s services" "${OPENVIDU_VERSION}"
     printf '\n'
     printf "\n     2. The previous file '.env' remains intact, but a new file '.env-%s' has been created." "${OPENVIDU_VERSION}"
     printf "\n     Transfer any configuration you wish to keep in the upgraded version from '.env' to '.env-%s'." "${OPENVIDU_VERSION}"
     printf "\n     When you are OK with it, rename and leave as the only '.env' file of the folder the new '.env-%s'." "${OPENVIDU_VERSION}" 
     printf '\n'
     printf "\n     3. If you were using Openvidu Call application, it has been automatically updated in file 'docker-compose.override.yml'."
     printf "\n     However, if you were using your own application, a file called 'docker-compose.override.yml-%s'" "${OPENVIDU_VERSION}"
     printf "\n     has been created with the latest version of Openvidu Call. If you don't plan to use it you can delete it."
     printf '\n'
     printf '\n     4. Start new version of Openvidu'
     printf '\n     $ ./openvidu start'
     printf '\n'
     printf "\n     If you want to rollback, all the files from the previous installation have been copied to folder '.old-%s'" "${OPENVIDU_PREVIOUS_VERSION}"
     printf '\n'
     printf '\n     For further information, check readme.md'
     printf '\n'
     printf '\n'
}

# Check docker and docker-compose installation
if ! command -v docker > /dev/null; then
     echo "You don't have docker installed, please install it and re-run the command"
     exit 0
fi

if ! command -v docker-compose > /dev/null; then
     echo "You don't have docker-compose installed, please install it and re-run the command"
     exit 0
else
     COMPOSE_VERSION=$(docker-compose version --short | sed "s/-rc[0-9]*//")
     if ! printf '%s\n%s\n' "1.24" "$COMPOSE_VERSION" | sort -V -C; then
          echo "You need a docker-compose version equal or higher than 1.24, please update your docker-compose and re-run the command"; \
          exit 0
     fi
fi

# Check type of installation
if [[ ! -z "$1" && "$1" == "upgrade" ]]; then
     upgrade_ov
else
     new_ov_installation
fi
