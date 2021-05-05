#!/usr/bin/env bash
set -xeufo pipefail

CODE=1

cleanup () {
  kill -9 "${SSH_PID}"
  exit $CODE
}

trap cleanup EXIT

LIBPROXYPROTO_MUST_USE_PROTOCOL_HEADER=1 LIBPROXYPROTO_DEBUG=1 $(pwd)/sshd -f $(pwd)/regress/sshd_config -o ListenAddress=::1 -o AddressFamily=any -De &
SSH_PID=$!
echo "started SSHd: ${SSH_PID}"
sleep 3

echo IPv6 address
LD_PRELOAD=libproxyproto/libproxyproto_connect.so LIBPROXYPROTO_ADDR=dead::beef ssh -6 -o ControlMaster=no -F $(pwd)/regress/ssh_config -o Hostname=::1 localhost env | grep -A 99 -B 99 '^SSH_CONNECTION=dead::beef 8080'

echo IPv4 address
LD_PRELOAD=libproxyproto/libproxyproto_connect.so LIBPROXYPROTO_ADDR=8.8.8.8 ssh -4 -o ControlMaster=no -F $(pwd)/regress/ssh_config -o Hostname=127.0.0.1 localhost env | grep -A 99 -B 99 '^SSH_CONNECTION=8.8.8.8 8080'

echo "passed"
CODE=0
