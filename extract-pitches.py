
import math
import sys

fcpu = 1789773.0 # NTSC cpu frequency in Hz

f = open(sys.argv[1], 'rb')
f.seek(16 + 0x1f00)
data = f.read(129)
for i in range(128):
    if data[i+1] != 0 and (data[i] & 0xf0) == 0:
        apu_pitch = ((data[i] & 0x7) * 256) + data[i+1]
        freq = fcpu / (16 * (apu_pitch + 1))
        print(hex(i), math.log2(freq / 261.63) * 12, freq)
f.close()
