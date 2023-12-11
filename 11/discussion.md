Solution Approach
=================

1. First, find the co-ords of all galaxies.
2. Now, take just the X/Y co-ords, sorted.
3. Expand each axis according to the expansion rule, which is just `add max(0, factor * (dist_to_prev - 1))`.
4. Take the dot product of the axis co-ords with `[-n + 1, -n + 3, ..., n - 3, n - 1]`.
5. Sum the two dot products.

The dot product thing comes from the following observation of the sum of all differences between `[a, b, c, d]`:

```
a_3              -a_0
a_3        -a_1
a_3  -a_2
      a_2        -a_0
      a_2  -a_1
            a_1  -a_0
```

That is, each number `a_0` ... `a_n` is used `n - 1` times in the sum, of which `i` times are positive.
