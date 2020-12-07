#!/bin/bash

NEW_UID="$(stat -c '%u' '/home/default')"
NEW_GID="$(stat -c '%g' '/home/default')"
groupadd -g "${NEW_GID}" pdi || true
useradd -d '/home/default' -g "${NEW_GID}" -u "${NEW_UID}" -N pdi || true
NEW_USER="$(getent passwd | awk -F: "\$3 == ${NEW_UID} { print \$1 }")"
NEW_GROUP="$(getent group  | awk -F: "\$3 == ${NEW_GID} { print \$1 }")"
exec runuser -u "${NEW_USER}" -- "$@"
