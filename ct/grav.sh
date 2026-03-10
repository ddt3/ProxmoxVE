#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/ddt3/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: Dries Dokter (ddt3)
# License: MIT | https://github.com/ddt3/ProxmoxVE/raw/main/LICENSE
# Source: https://getgrav.org/

## App Default Values
APP="Grav"
var_tags="${var_tags:-blog;cms}"
var_disk="${var_disk:-5}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /var/www/html/grav ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  $TSD cd /var/www/html/grav && sudo -u www-data php bin/gpm self-upgrade -f; sudo -u www-data php bin/gpm update -f
  msg_ok "Updated successfully!"
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN} ${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}/${CL}"
