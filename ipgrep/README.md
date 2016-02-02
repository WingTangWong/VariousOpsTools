# VariousOpsTools
Various Operations/Engineering Tools I find Useful

# Description: 

A friend of mine (Chris Haynie) posited an idea: igrep, which allows
you to grep ip addresses and cidr(S) against a file. After sketching out
some ideas, wrote up this bash shell wrapper that pre-processes the first
parameter as a potential cidr to be expanded into an egrep regex.

# License:

Public Domain. Ops folks always love tools.

# Pre-Requisites:
- nmap       - for cidr -> ip address list conversion
- egrep      - provides "grep functionality"
- sed/awk/tr - "massaging"

# Todo:
- handle multipl CIDR(s)
- mix/match CIDR(s) and normal egrep regexes
- maybe not rely on nmap for expansion

# Notes/Disclaimers:

This was a quick sketch written as a proof of concept... if you use
it for personal, production, or any kind of usage, I take no
responsibility for what may or may not happen in your environment/box/etc.

Ie, if your house/business/whatever burns down, don't blame me.

