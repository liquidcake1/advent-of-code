import sys
import numpy
print(sys.argv[1])
lines = [[numpy.array(list(map(int,y.split(",")))) for y in x.split("~")] for x in open(sys.argv[1], 'r').read().split("\n") if x]
print(lines)
lines.sort(key=lambda x: x[1][2])
heights = [[0 for _ in range(max(x[1][0] for x in lines) + 1)] for _ in range(max(x[1][1] for x in lines) + 1)]
highblocks = [[[] for _ in range(10)] for _ in range(10)]
useful = set()
supporters = [set() for _ in range(len(lines))]
supporter_counts = [0 for _ in range(len(lines))]
for i, (start, stop) in enumerate(lines):
    print(start, stop)
    print(heights)
    delta = (stop - start)
    l = delta.sum()
    step = delta // l
    curr = start.copy()
    minh = 0
    support = set()
    for _ in range(l + 1):
        print(curr, minh)
        h = heights[curr[0]][curr[1]] + 1
        if h > minh:
            support = set()
            minh = h
        if h >= minh:
            support.update(highblocks[curr[0]][curr[1]])
        curr += step
    if minh < start[2]:
        hdelta = start[2] - minh
        start[2] -= hdelta
        stop[2] -= hdelta
    support = list(support)
    if len(support) == 1:
        useful.update(support)
    seen = set()
    support_set = set()
    if support:
        support_set.update(supporters[support[0]])
    for supporter in support:
        support_set = support_set.intersection(supporters[supporter])
        print(f"Support for {i} set to {support_set}")
    if len(support) == 1:
        support_set.update(support)
    if support_set:
        supporters[i] = support_set
        for supporter in support_set:
            supporter_counts[supporter] += 1
    curr = start.copy()
    for _ in range(l + 1):
        print(curr)
        heights[curr[0]][curr[1]] = curr[2]
        highblocks[curr[0]][curr[1]] = [i]
        curr += step
    print(heights)
    print(len(lines) - len(useful))
    print(sum(supporter_counts))
print(supporter_counts)
print(sum(supporter_counts))
