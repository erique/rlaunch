#!/bin/bash

set -e

rm -rf tundra t2-build

echo -e "\033[1;36m****** TUNDRA ******\033[0m"

git clone --depth=1 --recurse-submodules https://github.com/deplinenoise/tundra.git t2-build
cd t2-build && make -j 4 && PREFIX=$PWD/../tundra make install && cd -
rm -rf t2-build
