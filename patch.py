
import sys

# usage: patch.py <zelda 1 rom.nes> <tune.bin>

tune = open(sys.argv[2], 'rb')
with tune:
    rom = open(sys.argv[1], 'r+b')

    with rom:
        rom.seek(6797)
        rom.write(tune.read())

