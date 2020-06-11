#!/usr/bin/env python3

import sys

if sys.version_info < (3,):
    print("Python 3 is required")
    sys.exit(1)

def convert(ly_data):
    print("convert "+repr(ly_data))
    return b''

if __name__ == '__main__':
    for arg in sys.argv[1:]:
        with open(arg, 'r') as f:
            data = f.read()
            print("converted to:", convert(data))

