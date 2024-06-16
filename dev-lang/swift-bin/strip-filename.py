import sys

if len(sys.argv) < 2:
    exit(1)

sys.stdout.write(''.join(sys.argv[1].split('-')[-4:-1]))
