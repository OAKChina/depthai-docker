#!/usr/bin/env bash

DEFAULT_TAG="latest"
IMAGE="richardarducam/depthai"
# Set the docker image
FINAL_IMAGE=${IMAGE}:${ARG_IMAGE:-${DEFAULT_TAG}}
#------------------------------------------------------------------------------
# Helpers
#
err() {
    echo -e >&2 "ERROR: $*\n"
}

die() {
    err "$*"
    exit 1
}

has() {
    # e.g. has command update
    local kind=$1
    local name=$2

    type -t "$kind:$name" | grep -q function
}

# If OCI_EXE is not already set, search for a container executor (OCI stands for "Open Container Initiative")
if [ -z "$OCI_EXE" ]; then
    if which docker >/dev/null 2>/dev/null; then
        OCI_EXE=docker
    elif which podman >/dev/null 2>/dev/null; then
        OCI_EXE=podman
    else
        die "Cannot find a container executor. Search for docker and podman."
    fi
fi

#------------------------------------------------------------------------------
# Command handlers
#
command:update-image() {
    $OCI_EXE pull "$FINAL_IMAGE"
}

command:update-script() {
    if cmp -s <( $OCI_EXE run --rm "$FINAL_IMAGE" ) "$0"; then
        echo "$0 is up-to-date"
    else
        echo -n "Updating $0 ... "
        $OCI_EXE run --rm "$FINAL_IMAGE" > "$0" && echo ok
    fi
}

command:update() {
    command:update-image
    command:update-script
}

command:help() {
  cat >&2 <<ENDHELP
Usage: depthai_env [options] [--] command

By default, run the given *command* in Docker container.

The *options* can be one of:

    --save|-s         Docker image tag to save
    --image|-i        Docker image tag to use
    --help|-h         Show this message

Additionally, there are special update commands:

    update-image      Pull the latest $FINAL_IMAGE.
    update-script     Update $0 from $FINAL_IMAGE.
    update            Pull the latest $FINAL_IMAGE, and then update $0 from that.

ENDHELP
}

#------------------------------------------------------------------------------
# Option processing
#
special_update_command=''
while [[ $# != 0 ]]; do
    case $1 in

        --)
            shift
            break
            ;;
        --save|-s)
            read -p " What tag should be saved (default: latest): " IMAGE_NAME
            IMAGE_NAME="${IMAGE_NAME:-latest}"
            echo "IMAGE NAME TO SAVE: ${IMAGE}:${IMAGE_NAME}"
            shift
            ;;
        --image|-i)
            # read -p " What tag should be used (default: latest): " ARG_IMAGE
            # ARG_IMAGE="${ARG_IMAGE:-latest}"
            ARG_IMAGE="$2"
            echo "IMAGE NAME TO USE: ${IMAGE}:${ARG_IMAGE}"
            shift
            ;;
        update|update-image|update-script)
            special_update_command=$1
            break
            ;;
        --help|-h)
            command:help
            exit
            ;;
        -*)
            err Unknown option \"$1\"
            command:help
            exit
            ;;
        *)
            break
            ;;

    esac
done

# The precedence for options is:
# 1. command-line arguments
# 2. environment variables
# 3. defaults

# Source the config file if it exists

# Handle special update command
if [ "$special_update_command" != "" ]; then
    case $special_update_command in

        update)
            command:update
            exit $?
            ;;

        update-image)
            command:update-image
            exit $?
            ;;

        update-script)
            command:update-script
            exit $?
            ;;

    esac
fi

HOST_PWD=$PWD
[ -L "$HOST_PWD" ] && HOST_PWD=$(readlink "$HOST_PWD")

#------------------------------------------------------------------------------
# Now, finally, run the command in a container
#
echo "OCI_EXE: $OCI_EXE"
TTY_ARGS=-ti
CONTAINER_NAME=depthai_$RANDOM
xhost local:root && \
$OCI_EXE run $TTY_ARGS --name $CONTAINER_NAME \
    --platform linux/amd64 \
    --privileged \
    --network=host \
    -v /dev/bus/usb:/dev/bus/usb \
    --device-cgroup-rule='c 189:* rmw' \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "$HOST_PWD":/workdir \
    -e XDG_RUNTIME_DIR=/usr/lib \
    "$FINAL_IMAGE" "$@"
run_exit_code=$?

if [ -z "${IMAGE_NAME}" ]; then
  $OCI_EXE tag "$FINAL_IMAGE" "$FINAL_IMAGE"_"$(date +%Y%m%d%H%M)"
  $OCI_EXE commit $CONTAINER_NAME ${IMAGE}:"${IMAGE_NAME}"
fi

# Attempt to delete container
rm_output=$($OCI_EXE rm -f $CONTAINER_NAME 2>&1)
rm_exit_code=$?
if [[ $rm_exit_code != 0 ]]; then
  if [[ "$CIRCLECI" == "true" ]] && [[ $rm_output == *"Driver btrfs failed to remove"* ]]; then
    : # Ignore error because of https://circleci.com/docs/docker-btrfs-error/
  else
    echo "$rm_output"
    exit $rm_exit_code
  fi
fi

exit $run_exit_code

################################################################################
#
# This image is not intended to be run manually.
#
# To create a helper script for the image, run:
#
# docker run --rm richardarducam/depthai:latest > depthai_env
# chmod +x depthai_env
#
# You may then wish to move the script to your PATH.
#
################################################################################
