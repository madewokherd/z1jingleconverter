
import sys

f = open(sys.argv[1], 'rb')
data = f.read()
for i in data:
    print(i)
f.close()

