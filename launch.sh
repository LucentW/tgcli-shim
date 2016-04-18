#!/bin/sh

while true; do
	lua tgcli-shim.lua
	echo 'tgcli-shim has stopped. ^C to exit.'
	sleep 5s
done
