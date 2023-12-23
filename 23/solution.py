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
DBG_NONE = 0
DBG_GRID_END = 3
DBG_POP = 5
DBG_UNFILTERED_DIRS = 6
DBG_FILTER_DIRS = 6
DBG_QUEUE = 5
DBG_GRID_EVERY = 7
debuglevel = DBG_NONE

check = modes[sys.argv[2]]
route = []
node_route = [('START', 0)]
node_out = open('graph.dot', 'w')
node_out.write("digraph {\n")
links = set()
i = 0
juncts = {'START': 1, 'END': 1}
for x in range(len(lines[0])):
    for y in range(len(lines)):
        if lines[y][x] == '#': continue
        c = 0
        for dx, dy in dir_to_vector:
            if x == len(lines[0]) - 1 or y == len(lines) - 1:
                continue
            if lines[y+dy][x+dx] != '#':
                c += 1
        if c > 2:
            n = 'n%i_%i' % (x, y)
            juncts[n] = c
            print("JUNCT", len(juncts), x, y, c)
# Make a graph
import collections
graph = collections.defaultdict(set)
while queue:
    loc, di, depth = queue.pop()
    if debuglevel >= DBG_POP: print("Pop", (loc, di, depth), len(queue), queue)
    while route and route[-1][1] > depth:
        #print("Popping ", route)
        ploc, _depth = route.pop()
        #seen[ploc[1]][ploc[0]] = None
    while node_route and node_route[-1][1] > depth:
        #print("Popping ", route)
        node_route.pop()
    if debuglevel >= DBG_GRID_EVERY: print_seen()
    route.append((loc, depth))
    x, y = loc
    possible_dirs = list(get_surrounds(x, y, reverse_dir(di)))
    if not seen[y][x]:
        seen[y][x] = depth
        if debuglevel >= DBG_UNFILTERED_DIRS: print(possible_dirs)
        for ndi, nc, new in possible_dirs:
            nx, ny = new
            if nc != '.' and not check(ndi, nc):
                if debuglevel >= DBG_FILTER_DIRS: print(f"Failed check {nc} {ndi} {dir_to_vector[ndi]} {reverse_dir(ndi)} {dir_to_sym[ndi]} {dir_to_sym[reverse_dir(ndi)]}")
                continue
            #if seen[ny][nx]:
            #    continue
            if debuglevel >= DBG_QUEUE: print("Enqueue", new, ndi)
            queue.append((new, ndi, depth + 1))
    if len(possible_dirs) > 1 or y == len(lines) - 1:
        if y == len(lines) - 1:
            n = 'END'
        else:
            n = 'n%i_%i' % loc
        node_route.append((n, depth))
        link = (node_route[-2][0], node_route[-1][0])
        graph[node_route[-2][0]].add((node_route[-1][0], node_route[-1][1] - node_route[-2][1]))
        graph[node_route[-1][0]].add((node_route[-2][0], node_route[-1][1] - node_route[-2][1]))
        if link not in links:
            links.add(link)
            print("LINK", node_route[-2][0], node_route[-1][0])
            node_out.write("%s -> %s\n" % (node_route[-2][0], node_route[-1][0]))
    if y == len(lines) - 1:
        if debuglevel >= DBG_GRID_END: print_seen()
        print("Done", depth)
node_out.write("}\n")
if len(graph) != len(juncts):
    print("Mismatch in lengths", len(graph), len(juncts))
    for i in set(graph) - set(juncts):
        print("Missing in juncts:", i)
    for i in set(juncts) - set(graph):
        print("Missing in graph:", i)
    raise Exception()
for i in juncts:
    if juncts[i] != len(graph[i]):
        print("Mismatch in valency", i)
queue = [(None, 'START', 0)]
seen = set([None])
route = [(None, 0)]
m = 0
while queue:
    last, current, depth = queue.pop()
    #print(current, depth)
    #print(route)
    while last != route[-1][0]:
        popped_node, _ = route.pop()
        seen.remove(popped_node)
    route.append((current, depth))
    seen.add(current)
    #print(route)
    if current == 'END':
        if depth > m:
            print(route)
            print(depth)
            m = depth
    import random
    for i, l in sorted(graph[current], key=lambda _:random.uniform(0, 1)):
        if i in seen:
            continue
        #print(f"Queue {i} {l} from {current}")
        queue.append((current, i, depth+l))
