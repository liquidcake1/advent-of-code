import sys
import numpy
import scipy
np = numpy
lines = open(sys.argv[1], 'r').read().split('\n')[:-1]
def get_intersect(a, av, b, bv):
    """ 
    Returns the point of intersection of the lines passing through a2,a1 and b2,b1.
    a1: [x, y] a point on the first line
    a2: [x, y] another point on the first line
    b1: [x, y] a point on the second line
    b2: [x, y] another point on the second line
    """
    #print(a, b, av, bv)
    a1 = a[:2]
    b1 = b[:2]
    a2 = a1 + av[:2]
    b2 = b1 + bv[:2]
    #print(a1, b1, a2, b2)
    s = np.vstack([a1,a2,b1,b2])        # s for stacked
    h = np.hstack((s, np.ones((4, 1)))) # h for homogeneous
    l1 = np.cross(h[0], h[1])           # get first line
    l2 = np.cross(h[2], h[3])           # get second line
    x, y, z = np.cross(l1, l2)          # point of intersection
    if z == 0:                          # lines are parallel
        return None
        #return (float('inf'), float('inf'))
    #return (x/z, y/z)
    if abs(x/z - a1[0]) > 1e-10:
        at = (x/z - a1[0]) / av[0]
    elif abs(y/z - a1[1]) > 1e-10:
        at = (y/z - a1[0]) / av[0]
    else:
        at = 0
    if abs(x/z - b1[0]) > 1e-10:
        bt = (x/z - b1[0]) / bv[0]
    elif abs(y/z - b1[1]) > 1e-10:
        bt = (y/z - b1[0]) / bv[0]
    else:
        bt = 0
    return (a + av * at, b + bv * bt)
starts = [numpy.array([float(x.strip()) for x in line.split(' @ ')[0].split(',')]) for line in lines]
vels = [numpy.array([float(x.strip()) for x in line.split(' @ ')[1].split(',')]) for line in lines]
print(vels)
def wrongness(start_and_vel):
    start = numpy.array([229078419153034.] + list(start_and_vel[:2]))
    vel = numpy.array([1] + list(start_and_vel[2:]))
    dist = 0
    print(start, vel)
    for i in range(5):
        intersect = get_intersect(starts[i], vels[i], start, vel)
        if intersect is None:
            dist += 1.e20
            continue
        #print(start, vel, starts[i], vels[i], intersect)
        dist += (intersect[0][2] - intersect[1][2]) ** 2
    print(dist)
    return dist
print(get_intersect(starts[0], vels[0], starts[1], vels[1]))
#ans = scipy.optimize.minimize(wrongness, numpy.array([1.0e4, 1.0e4, 1.23e4, 1.31e4, 1.22e4]), method='BFGS', options=dict(gtol=1e-60, eps=10, maxiter=1000000))
#ans = scipy.optimize.minimize(wrongness, numpy.array([229078419153034., 229078419153034., 1.0, 1.0]), method='L-BFGS-B', options=dict(gtol=1e-60, eps=numpy.array([1.e14, 1.e14, 1.0, 1.0]), maxiter=1000000))
#ans = scipy.optimize.differential_evolution(wrongness, [[0, 1e15], [0, 1e15], [-1e4, 1e4], [-1e4, 1e4], [-1e4, 1e4]])
ans = scipy.optimize.differential_evolution(wrongness, [[0, 1e4], [0, 1e4], [-1e4, 1e4], [-1e4, 1e4]])
print(ans)
