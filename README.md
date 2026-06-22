# Olive C3 Graphics Examples

A simple software rendering playground written in the C3 programming language using a custom graphics library (`olive`). It generates various procedural patterns and shapes, exporting them directly to `.ppm` image files.

## Features
- **Checkerboard Example**: Alternating procedural tile grid.
- **Circle Example**: Grid of circles drawn using pixel bounding boxes.
- **Line Example**: Line-burst structures utilizing Bresenham's Line Algorithm.

## Requirements
- [C3 Compiler](https://c3-lang.org/) (`c3c`)
- A Unix-like environment (Linux/macOS) or Git Bash on Windows to run the shell script.

## How to Build and Run
Execute the provided build script to compile and run the examples automatically:

```bash
chmod +x build.sh
./build.sh