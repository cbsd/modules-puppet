#!/bin/sh

pgm="${0##*/}" # Program basename
progdir="${0%/*}" # Program directory

if [ -z "${1}" ]; then
	echo "usage ${pgm} domain"
	exit 1
fi

. ${progdir}/config

pdnsutil create-zone ${1}
