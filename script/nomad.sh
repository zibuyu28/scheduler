#!/bin/bash

set -e

function runjob() {
  echo "Running job $1"
  nomad job run "$1"
}

function start_dev_nomad() {
  echo "Starting Nomad in dev mode"
  nohup nomad agent -dev -bind '0.0.0.0' > nomad.log 2>&1 &
}

function nomad_log() {
  tail -f nomad.log
}

function check_nomad_installed() {
  if ! command -v nomad &> /dev/null
  then
    echo "Nomad could not be found. Please install it first."
    return 1
  fi
}

function nomad_stop() {
  echo "Stopping Nomad..."
  pkill nomad || exit 0
}

case "$1" in
  start)
    start_dev_nomad
    ;;
  check)
    check_nomad_installed
    ;;
  log)
    nomad_log
    ;;
  stop)
    nomad_stop
    ;;
  job)
    runjob "${@:2}"
    ;;
  *)
    echo "Invalid selection, please enter a number between 1 and 3."
    ;;
esac
