import sys
import collections
import time

lines = list(line.strip() for line in sys.stdin)
rev = collections.defaultdict(list)
for line in lines:
    lhs, rhs = line.split(":")
    outputs = rhs.strip().split(" ")
    for output in outputs:
        rev[output].append(lhs)

def explore(item, cache):
    try:
        return cache[item]
    except KeyError:
        pass

    ret = sum(explore(parent, cache) for parent in rev[item])
    cache[item] = ret
    return ret

s = time.time()
part1 = explore("out", {"you": 1})

print(part1, time.time() - s)

def explore_path(path):
    subs = zip(path[:-1], path[1:])
    ans = 1
    for first, second in subs:
        ans *= explore(first, {second: 1})
    return ans
    
s = time.time()
dac_first = explore_path(["out", "dac", "fft", "svr"])
fft_first = explore_path(["out", "fft", "dac", "svr"])
print(fft_first, dac_first, fft_first + dac_first, time.time() - s)
