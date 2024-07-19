#!/bin/bash

dotnet tool update TinyFx.Tools.UbuntuCmds -g --no-cache http://10.0.0.101:5555/v3/index.json
tcmd update -s http://10.0.0.101:5555/v3/index.json
tcmd linux-alias -a -n dps -c 'tcmd docker-ps'