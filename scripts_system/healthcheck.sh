#!/bin/bash
set -eu
export LANGUAGE=C.UTF-8

if ! supervisorctl status | grep --invert-match -E "(STARTING|RUNNING)"; then
    # if the 2 process is alive, assume everything's OK
    exit 0
else
    # the world is on fire!
    exit 1
fi
