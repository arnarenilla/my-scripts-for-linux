#!/bin/bash

SERVER="192.168.173.252"
USERNAME="arnela"

xfreerdp \
    /v:$SERVER \
    /u:$USERNAME \
    /multimon \
    /f \
    /sound:sys:alsa \
    /microphone:sys:alsa \
    /video \
    +clipboard \
    /drive:Downloads,$HOME/Downloads \
    /cert:ignore
