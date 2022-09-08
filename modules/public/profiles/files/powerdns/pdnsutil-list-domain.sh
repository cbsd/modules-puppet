#!/bin/sh

pgm="${0##*/}" # Program basename
progdir="${0%/*}" # Program directory

. ${progdir}/config

pdnsutil list-all-zones
