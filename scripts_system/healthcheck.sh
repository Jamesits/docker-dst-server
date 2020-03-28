#!/bin/bash
set -eu

if [ "$(supervisorctl status | grep --invert-match --count RUNNING)" == 0 ]; then
    # if the 2 process is alive, assume everything's OK
    exit 0
else
    # the world is on fire!
    exit 1
fi
