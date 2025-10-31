#!/usr/bin/env bash
set -e

# Dynamic user remapping entrypoint
USER_NAME=${USER_NAME:-multiomics}
USER_HOME="/home/${USER_NAME}"

# PUID/PGID are passed from the host via docker-compose environment variables
# Default to the UID/GID baked into the image (1000)
PUID=${PUID:-1000}
PGID=${PGID:-1000}

# 1. Ensure group exists and matches PGID
# Check if the group name exists. If so, modify its GID; otherwise, add it.
if ! getent group "${USER_NAME}" >/dev/null 2>&1; then
    groupadd -g "${PGID}" "${USER_NAME}" >/dev/null 2>&1 || true
else
    # -o allows non-unique GID; we change the existing group's GID
    groupmod -o -g "${PGID}" "${USER_NAME}" >/dev/null 2>&1 || true
fi

# 2. Ensure user exists and matches PUID
# Check if the user name exists. If so, modify its UID; otherwise, add it.
if ! id -u "${USER_NAME}" >/dev/null 2>&1; then
    useradd -m -u "${PUID}" -g "${PGID}" -s /bin/bash "${USER_NAME}" >/dev/null 2>&1 || true
else
    # -o allows non-unique UID; we change the existing user's UID and link to the new GID
    usermod -o -u "${PUID}" -g "${PGID}" "${USER_NAME}" >/dev/null 2>&1 || true
fi

# 3. Ensure correct permissions for mounted volumes (Run as root)
# Fix permissions on all mounted directories to ensure the new UID/GID can write.
for dir in "${USER_HOME}" "${USER_HOME}/results" "${USER_HOME}/work" "${USER_HOME}/.nextflow"; do
    if [ -d "$dir" ]; then
        # Recursively change ownership only on existing directories
        chown -R "${PUID}:${PGID}" "$dir" >/dev/null 2>&1 || true
    else
        # Create directory if it doesn't exist and set ownership
        mkdir -p "$dir"
        chown "${PUID}:${PGID}" "$dir"
    fi
done

# 4. Drop privileges and execute command
if [ $# -eq 0 ]; then
    exec gosu "${USER_NAME}" bash
else
    exec gosu "${USER_NAME}" "$@"
fi
