#!/bin/sh

ACTION=${1}
shift 1

do_install() {
  local port=`uci get pikvm.@main[0].port 2>/dev/null`
  local image_name=`uci get pikvm.@main[0].image_name 2>/dev/null`
  local hid=`uci get pikvm.@main[0].hid 2>/dev/null`
  local video=`uci get pikvm.@main[0].video 2>/dev/null`

  [ -z "$image_name" ] && image_name="ziguayungui/pikvm-docker-x86:v3.308"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f pikvm

  [ -z "$port" ] && port=8443
  [ -z "$hid" ] && hid="/dev/ttyUSB0"
  [ -z "$video" ] && video="/dev/video0"

  local cmd="docker run --restart=unless-stopped -d -h PiKVMServer --device=$hid:/dev/kvmd-hid --device=$video:/dev/kvmd-video "

  cmd="$cmd\
  --dns=172.17.0.1 \
  -p $port:443 "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd --name pikvm \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the pikvm"
  echo "      upgrade                Upgrade the pikvm"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the pikvm"
  echo "      status                 PiKVM status"
  echo "      port                   PiKVM port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f pikvm
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} pikvm
  ;;
  "status")
    docker ps --all -f 'name=pikvm' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=pikvm' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->8080/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  *)
    usage
    exit 1
  ;;
esac
