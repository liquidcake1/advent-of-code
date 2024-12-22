file := File clone openForReading(System args at(1))
lines := file readLines
#lines foreach(i, line, write(line, "\n"))
#write("E" at(0), "\n")
# S is 83
# E is 69
# # is 35
# . is 46
start_x := nil
start_y := nil
route := List clone
lines foreach(i, line, (
      route_r := List clone
      for(j, 1, line size, route_r append(nil))
      route append(route_r)
      x := line findSeq("S")
      (x != nil) ifTrue (start_y = i; start_x = x)
      )
    )
start_y print
"\n" print
start_x print
"\n" print

# Explore the initial route
curr := List clone append(start_x, start_y)
dirs := List clone append(
  List clone append(0, 1),
  List clone append(1, 0),
  List clone append(0, -1),
  List clone append(-1, 0)
)
shortcut_counts := 0
for(i, 1, (lines size) * (lines at(0) size), (
  # Find shortcut back
  dirs foreach(j, dir, (
    target := list(0, 1) map (j, (curr at(j)) + (dir at(j) * 2))
    #"Dir " print; dir print; "\n" print
    (target at(0) < 0) ifTrue(continue)
    #"x over 0\n" print
    (target at(1) < 0) ifTrue(continue)
    #"y over 0\n" print
    (target at(1) >= lines size) ifTrue(continue)
    #"x not too high\n" print
    (target at(0) >= lines at(target at(1)) size) ifTrue(continue)
    #"y not too high\n" print
    (route at(target at(1)) at(target at(0)) == nil) ifTrue(continue)
    #"dir seen\n" print
    (route at(target at(1)) at(target at(0)) >= i - 101) ifTrue(continue)
    "Shortcut found at " print; target print; ": " print; (route at(target at(1)) at(target at(0)) - (i - 2)) print; "\n" print
    shortcut_counts = shortcut_counts + 1
  ))
  route at(curr at(1)) atPut(curr at(0), i)
  (lines at(curr at(1)) at(curr at(0)) == 69) ifTrue(
    "End at " print; i print; "\n" print
    break)
  #curr print; "\n" print
  # Find new dir
  new := nil
  dirs foreach(j, dir, (
    target := list(0, 1) map (j, (curr at(j)) + (dir at(j)))
    #"Dir " print; dir print; "\n" print
    (target at(0) < 0) ifTrue(continue)
    #"x over 0\n" print
    (target at(1) < 0) ifTrue(continue)
    #"y over 0\n" print
    (target at(0) >= lines size) ifTrue(continue)
    #"x not too high\n" print
    (target at(0) >= lines at(target at(1)) size) ifTrue(continue)
    #"y not too high\n" print
    (lines at(target at(1)) at(target at(0)) == 35) ifTrue(continue)
    #"lines not hash\n" print
    (route at(target at(1)) at(target at(0)) != nil) ifTrue(continue)
    #"dir not seen\n" print
    new = target
    break
  ))
  (new == nil) ifTrue(
    "Not moved!\n" print
    break
    )
  curr = new
  ))
shortcut_counts print
file close
