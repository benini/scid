#!/bin/sh
rm -rf scid_pocket/*
cp *.tcl toga/src/toga.exe ../tkscid.dll scid_pocket/
cp -r search scid_pocket
cp -r utils scid_pocket
cp -r books scid_pocket
zip -r scidpocket_`date +%d%m%y_%Hh%M` scid_pocket/*

