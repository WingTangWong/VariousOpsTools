#!/usr/bin/env bash
# 
# Description: 
# 
# A friend of mine (Chris Haynie) posited an idea: igrep, which allows
# you to grep ip addresses and cidr(S) against a file. After sketching out
# some ideas, wrote up this bash shell wrapper that pre-processes the first
# parameter as a potential cidr to be expanded into an egrep regex.
# 
# License:
#
# Public Domain. Ops folks always love tools.
#
# Pre-Requisites:
# - nmap       - for cidr -> ip address list conversion
# - egrep      - provides "grep functionality"
# - sed/awk/tr - "massaging"
#
# Todo:
# - handle multipl CIDR(s)
# - mix/match CIDR(s) and normal egrep regexes
# - maybe not rely on nmap for expansion
#
# Notes/Disclaimers:
#
# This was a quick sketch written as a proof of concept... if you use
# it for personal, production, or any kind of usage, I take no
# responsibility for what may or may not happen in your environment/box/etc.
# 
# Ie, if your house/business/whatever burns down, don't blame me.
#

PID=$$
REGEXFILE=/tmp/${PID}.regex
NEGREGEXFILE=/tmp/${PID}.negregex
rm -f ${REGEXFILE} 2>/dev/null

# No params... just exit
if [ $# -lt 1 ]; then
  exit 0
fi
cidr=$1


if [[ $cidr =~ ^[1-90][1-90]*[.][1-90][1-90]*[.][1-90][1-90]*[.][1-90][1-90]*[/][1-90][1-90]*$ ]]; then
  shift
  nmap -sL ${cidr} -sn -Pn --disable-arp-ping -n  2>/dev/null | \
    egrep "scan report" | awk '{print $NF}' | \
    sed -e 's/[ ][ ]*//g' | tr '\012' '|' | \
    sed -e 's/^[|]//' -e 's/[|]$//' -e 's/[|][|]*/|/g' > ${REGEXFILE}

  nmap -sL ${cidr} -sn -Pn --disable-arp-ping -n  2>/dev/null | \
    egrep "scan report" | awk '{print $NF}' | \
    sed -e 's/[ ][ ]*//g' -e 's/^/[1-90]/' | tr '\012' '|' | \
    sed -e 's/^[|]//' -e 's/[|]$//' -e 's/[|][|]*/|/g' > ${NEGREGEXFILE}

  nmap -sL ${cidr} -sn -Pn --disable-arp-ping -n  2>/dev/null | \
    egrep "scan report" | awk '{print $NF}' | \
    sed -e 's/[ ][ ]*//g' -e 's/$/[1-90]/'  | tr '\012' '|' | \
    sed -e 's/^[|]//' -e 's/[|]$//' -e 's/[|][|]*/|/g' >> ${NEGREGEXFILE}

else
  if [[ $cidr =~ ^[1-90][1-90]*[.][1-90][1-90]*[.][1-90][1-90]*[.][1-90][1-90]*$ ]]; then
    shift
    echo "${cidr}" > ${REGEXFILE}
    echo "[1-90]${cidr}" > ${NEGREGEXFILE}
    echo "${cidr}[1-90]" > ${NEGREGEXFILE}
  fi
fi

if [ -f ${REGEXFILE} ]; then
  egrep -f ${REGEXFILE} $* | egrep -v -f ${NEGREGEXFILE}
#  rm -f ${REGEXFILE}
#  rm -f ${NEGREGEXFILE}
else
  egrep $*
fi

