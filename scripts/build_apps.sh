#!/bin/bash -eux

readonly APPS_PATH=./src/apps

# shellcheck disable=SC1090
source ~/osbook/devenv/buildenv.sh

for makefile in $(ls $APPS_PATH/*/Makefile)
do
  APP_DIR=$(dirname $makefile)
  APP=$(basename $APP_DIR)
  make ${MAKE_OPTS:-} -C $APP_DIR
done
