#!/bin/bash
scalac "$1" && scala -J-Xmx4096m -J-Xms4096m "${1%.scala}" "$2"
