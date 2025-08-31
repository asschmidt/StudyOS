#!/bin/sh

# Run GDB using the parameters passed in
exec /usr/bin/gdb --init-eval-command="set architecture i386:x86-64" "$@"