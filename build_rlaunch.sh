#!/bin/bash

set -e

echo -e "\033[1;32m****** RLAUNCH (HOST) ******\033[0m"

VBCC=$PWD/vbcc PATH=$PATH:$PWD/tundra/bin tundra2 release

echo -e "\033[1;32m****** RLAUNCH (TARGET) ******\033[0m"

VBCC=$PWD/vbcc PATH=$PATH:$PWD/tundra/bin tundra2 -j 1 amiga-vbcc-release

echo -e "\033[1;32m****** DONE ******\033[0m"

find t2-output -type f -name "rl-controller*" -or -name "rl-target"