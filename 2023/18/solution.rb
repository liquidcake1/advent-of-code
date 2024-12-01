# Pass filename, then optionally 'part2' for the second part.
# Solution basically just re-implemented from Day 10.
lines = File.readlines(ARGV[0], chomp: true)
pos = [0, 0]
puts pos.to_s
dirs = {"U" => [0, -1], "D" => [0, 1], "L" => [-1, 0], "R" => [1, 0]}
lastdir, _, _ = lines[-1].split(' ')
require 'set'
clockwise = Set["UR", "RD", "DL", "LU"]
pm_map = {"UR" => -1, "RD" => 1, "DL" => 1, "LU" => -1, "UL" => 0, "LD" => 0, "DR" => 0, "RU" => 0}
area = 0
area2 = 0
pos2 = [0, 0]
lines.each do |line|
  puts line
  dir, len_s, col_s = line.split(' ')
  if ARGV[1] == "part2"
    len = col_s[2..-3].to_i(16)
    dir = "RDLU"[col_s[-2].to_i]
  else
    len = len_s.to_i
  end
  puts [dir, len].to_s
  dirv = dirs[dir]

  corner = lastdir + dir
  puts corner
  cmul = pm_map[corner]

  aadd = cmul * pos[0]
  if cmul == 1
    aadd += 1
  end
  area += aadd
  puts ["area after corner", aadd, corner, pm_map[corner], area].to_s
  ladd = dirv[1] * pos[0]
  if dirv[1] == 1
    ladd += 1
  end
  area += ladd * (len - 1)
  puts ["area after straight", ladd, len - 1, dir, dirv.to_s, area].to_s

  pos = [pos[0] + dirv[0] * len, pos[1] + dirv[1] * len]
  puts pos.to_s
  lastdir = dir
end
