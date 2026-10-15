# Databases and API tools.
# shellcheck shell=bash
module_postgres() {
  step "PostgreSQL server + pgAdmin 4"
  dnf_install postgresql-server postgresql-contrib
  if [[ ! -f /var/lib/pgsql/data/PG_VERSION ]]; then
    $SUDO postgresql-setup --initdb >>"$TOS_LOG" 2>&1 || warn "postgresql initdb failed (see log)"
  fi
  $SUDO systemctl enable --now postgresql >>"$TOS_LOG" 2>&1 || true
  repo_pgadmin; dnf_install pgadmin4-desktop
}

module_mysql() {
  step "MySQL 8.4 Community server + MySQL Workbench"
  repo_mysql
  dnf_install mysql-community-server
  # Oracle publishes Workbench for Fedora only sporadically (none for f44 at time of writing).
  if dnf -q repoquery mysql-workbench-community 2>/dev/null | grep -q .; then
    dnf_install mysql-workbench-community
  else
    warn "MySQL Workbench has no package for Fedora $FEDORA yet; opening the download page. DBeaver (DB & API tools) also covers MySQL."
    xdg-open https://dev.mysql.com/downloads/workbench/ >/dev/null 2>&1 &
  fi
  $SUDO systemctl enable --now mysqld >>"$TOS_LOG" 2>&1 || true
  local tmp; tmp=$($SUDO grep -h 'temporary password' /var/log/mysqld.log 2>/dev/null | tail -1 | awk '{print $NF}')
  [[ -n $tmp ]] && warn "MySQL root temporary password is in /var/log/mysqld.log — change it with: mysql_secure_installation"
}

module_apitools() {
  step "DBeaver CE + Bruno (Flathub)"
  flatpak_install io.dbeaver.DBeaverCommunity com.usebruno.Bruno
}
