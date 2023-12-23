import sys
lines = open(sys.argv[1]).read().split('\n')[:-1]
dir_to_sym = ['v', '>', '^', '<']
sym_to_dir = dict((y,x) for x,y in enumerate(dir_to_sym))
dir_to_vector = [(0, 1), (1, 0), (0, -1), (-1, 0)]
def reverse_dir(d):
    return (d + 2) % 4
modes = {
    'part1': lambda d, s: sym_to_dir[s] != reverse_dir(d),
    'part2': lambda d, s: True,
}

queue = [((1, 0), 0, 0)]
seen = [[None for _ in range(len(lines[0]))] for _ in range(len(lines))]
depth = 0
def get_surrounds(x, y, ii):
    for i, di in enumerate(dir_to_vector):
        if i == ii:
            continue
        xd, yd = di
        nx = x + xd
        if nx < 1 or nx >= len(lines[0]) - 1:
            continue
        ny = y + yd
        if ny < 1 or ny >= len(lines):
            continue
        c = lines[ny][nx]
        if c == '#':
            continue
        yield i, c, (nx, ny)
def print_seen():
    print(" ".join("%3i" % (x,) if x is not None else "   " for x in [None] + list(range(len(lines[0])))))
    for i, row in enumerate(seen):
        print(" ".join("%3i" % (x,) if x is not None else "   " for x in [i] + row))
    print(" ".join("%3i" % (x,) if x is not None else "   " for x in [None] + list(range(len(lines[0])))))
check = modes[sys.argv[2]]
route = []
DBG_NONE = 0
DBG_GRID_END = 3
DBG_POP = 5
DBG_UNFILTERED_DIRS = 6
DBG_FILTER_DIRS = 6
DBG_QUEUE = 5
DBG_GRID_EVERY = 7
debuglevel = DBG_NONE
while queue:
    loc, di, depth = queue.pop()
    if debuglevel >= DBG_POP: print("Pop", (loc, di, depth), len(queue), queue)
    while route and route[-1][1] >= depth:
        #print("Popping ", route)
        ploc, _depth = route.pop()
        seen[ploc[1]][ploc[0]] = None
    if debuglevel >= DBG_GRID_EVERY: print_seen()
    route.append((loc, depth))
    x, y = loc
    seen[y][x] = depth
    possible_dirs = list(get_surrounds(x, y, reverse_dir(di)))
    if debuglevel >= DBG_UNFILTERED_DIRS: print(possible_dirs)
    for ndi, nc, new in possible_dirs:
        nx, ny = new
        if nc != '.' and not check(ndi, nc):
            if debuglevel >= DBG_FILTER_DIRS: print(f"Failed check {nc} {ndi} {dir_to_vector[ndi]} {reverse_dir(ndi)} {dir_to_sym[ndi]} {dir_to_sym[reverse_dir(ndi)]}")
            continue
        if seen[ny][nx]:
            continue
        if debuglevel >= DBG_QUEUE: print("Enqueue", new, ndi)
        queue.append((new, ndi, depth + 1))
    if y == len(lines) - 1:
        if debuglevel >= DBG_GRID_END: print_seen()
        print("Done", depth)
