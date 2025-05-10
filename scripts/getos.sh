#!/bin/sh
OS=Unknown
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    if [ -f /etc/kylin-release ]; then
        OS=kylinorcentos
    elif [ -f /etc/centos-release ]; then
        OS=kylinorcentos
    elif [ -f /etc/redhat-release ]; then
        OS=redhat
    elif [ -f /etc/SuSE-release ]; then
        OS=suse
    elif [ -f /etc/arch-release ]; then
        OS=arch
    elif [ -f /etc/mandrake-release ]; then
        OS=mandrake
    elif [ -f /etc/debian_version ]; then
        OS=ubuntuordebian
    else
        OS=unknown
        echo "Unknown Linux distribution."
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS=macos
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    OS=FreeBSD
else
    echo "Unknown operating system."
    OS=unknown
fi
