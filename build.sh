#!/bin/sh

set -e

echo "Building project..."
c3c compile example.c3 olive.c3 -o example

echo "Running application..."
./example

echo "Done! Generated .ppm files successfully."