Algorithm for Part 2
====================

See [Discussion 1](discussion.md) for background.

Assume we go around clockwise. Then any "clockwise" turn is concave
and any "anticlockwise" turn is convex. `LD` and `DR` turns mark right
edges and `RU` and `UL` edges mark left edges. Any upward vertical
line is a left edge and any downward vertical line is a right edge.
Horizontal lines are top/bottom edges, so not interesting. We need to
wait until we get back to `S` to work out what kind of edge it is.

Run around the loop simply accumulating all of the edge points that we
find. This is the internal area.

If we reach the end and found we went backwards, that's OK: we've just
got a negative number -- take the absolute value, instead.
