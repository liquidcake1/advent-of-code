import sys
count = int(sys.argv[1])
size = int(sys.argv[2])
length = int(sys.argv[3])
import random
start = [random.randint(0, size * length) for _ in range(3)]
vel = [random.randint(-size, size) for _ in range(3)]
print("Ans: " + ", ".join(map(str, start)) + " @ " + ", ".join(map(str, vel)), file=sys.stderr)
for _ in range(count):
    dist = random.randint(0, length)
    intersect = [p+dist*v for p,v in zip(start, vel)]
    pvel = [random.randint(-size, size) for _ in range(3)]
    print("Intersect: " + ", ".join(map(str, intersect)) + " Dist " + str(dist), file=sys.stderr)
    pstart = [p-dist*v for p,v in zip(intersect, pvel)]
    print(", ".join(map(str, pstart)) + " @ " + ", ".join(map(str, pvel)))
    
