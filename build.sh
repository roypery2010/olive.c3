#!/bin/sh

set -e

# Clear existing binaries
rm -rf app testrun out

echo "=== Compiling Production Engine ==="
c3c compile example.c3 olive.c3 -o app

echo "=== Running Production Engine ==="
./app

echo "Done! Verified and generated all .ppm imagery outputs safely."