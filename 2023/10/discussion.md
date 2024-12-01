Part 2
======

I drew the following diagrams:

```
A: -....+    -....+
B: -....+    -....+
C: -....+    -.0..+
D: -..0.+      -..+
E: -..+        -..+
F: -..0........0..+
G: -..............+
H: -..............+
```

```
A: 0~~~~0    0~~~~0
B: -....+    -....+
C: -....+    0~-..+
D: -..+~0      -..+
E: -..+        -..+
F: -..+~~~~~~~~-..+
G: -..............+
H: 0~~~~~~~~~~~~~~0
```

Basically the first is if I want to include the path; the second to
exclude it. A `-` means "subtract this co-ordinate (plus an extra 1
for inside)", a `+` means "add this co-ordinate (plus 1 for outside)".
A `0` means "ignore this co-ordinate", as does anything else.

For example, on the second diagram row `H` has nothing internal. and
row `D` has `-(0+1) + 3 -(12+1) + 15 = 3-1 + 15-13 = 4` inside points.

See [Discussion 2](discussion2.md) for algorithm, which is more
spoilery.
