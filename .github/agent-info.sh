#!/usr/bin/env bash

function info () {
    echo >&2 "===]> Info: $* ";
}

info "Print information about agent..."

echo -e '\n'
info "uname -a"
uname -a
echo -e '\n'

info "CPU threads: $(nproc --all)"
info "CPU $(grep 'model name' /proc/cpuinfo | uniq)"
info "CPU freq:"
grep 'MHz' /proc/cpuinfo
echo -e '\n'

info "Egress Public IP: $(curl -4 -s ifconfig.co)"
echo -e '\n'

info "pwd"
pwd
echo -e '\n'

info "df -h"
df -h
echo -e '\n'

info "free -m"
free -m
echo -e '\n'

info "w"
w
echo -e '\n'

info "Top 5 processes sorted by CPU usage..."
ps -Ao user,uid,pid,pcpu,pmem,command,cmd --sort=-pcpu | head -n 6
echo -e '\n'

info "Top 5 processes sorted by MEM usage..."
ps -Ao user,uid,pid,pcpu,pmem,command,cmd --sort=-pmem | head -n 6
echo -e '\n'
