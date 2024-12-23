package main
import "fmt"
import "os"
import "strconv"
import "strings"

func abs(x int) int {
	if x < 0 { return -x }
	return x
}

func ncr(n, r int) int {
	// n! / (r! (n-r)!)
	var ans int
	ans = 1
	for i := r + 1; i <= n; i++ {
		ans *= i
	}
	for i := 2; i <= n - r; i++ {
		ans /= i
	}
	return ans
}

const depth = 25

func main() {
	var key_locs = map[string][2]int {
		"0": {1, 3},
		"1": {0, 2},
		"2": {1, 2},
		"3": {2, 2},
		"4": {0, 1},
		"5": {1, 1},
		"6": {2, 1},
		"7": {0, 0},
		"8": {1, 0},
		"9": {2, 0},
		"A": {2, 3},
		"dead": {0, 3},
	}

	var dir_locs = map[string][2]int{
		"<": {0, 1},
		"v": {1, 1},
		">": {2, 1},
		"^": {1, 0},
		"A": {2, 0},
		"dead": {0, 0},
	}

	var key_lookup = make([]map[string][2]int, depth + 1)
	key_lookup[0] = key_locs
	for i:= 1; i<depth + 1; i++ {
		key_lookup[i] = dir_locs
	}

	dat, err := os.ReadFile(os.Args[1])
	if err != nil {panic(err)}
	//fmt.Print(string(dat))
	//fmt.Print(shortest_outer_path_for_button_press(key_lookup[0]["A"], key_lookup[0]["0"], key_lookup[0]["dead"], key_lookup[1:1]), "\n")
	//fmt.Print(shortest_outer_path_for_button_press(key_lookup[0]["A"], key_lookup[0]["0"], key_lookup[0]["dead"], key_lookup[1:2]), "\n")
	//fmt.Print(shortest_outer_path_for_button_press(key_lookup[0]["A"], key_lookup[0]["0"], key_lookup[0]["dead"], key_lookup[1:3]), "\n")
	var cache = make([][3][4][3][4]int64, depth + 2)
	for i:=0; i<depth + 2; i++ {
		for sx:=0; sx<3; sx++ {
			for sy:=0; sy<3; sy++ {
				for ex:=0; ex<3; ex++ {
					for ey:=0; ey<3; ey++ {
						cache[i][sx][sy][ex][ey] = 0
					}
				}
			}
		}
	}

	inputs := strings.Split(string(dat), "\n")
	//fmt.Print(inputs)
	total := int64(0)
	for i:=0; i<len(inputs)-1; i++ {
		val, _ := strconv.ParseInt(inputs[i][:len(inputs[i])-1], 10, 64)
		best_route_len := shortest_outer_path_for_inner_path(key_lookup, inputs[i], cache)
		score := val * best_route_len
		fmt.Print(inputs[i], ": ", best_route_len, "\n")
		fmt.Print(score, " = ", best_route_len, " * ", val, "\n")
		total += score
	}
	fmt.Print(total, "\n")
}

func repeat(s string, n int) string {
	ans := ""
	for i := 0; i<n; i++ {
		ans = ans + s
	}
	return ans
}

func gen_paths(source [2]int, target [2]int, dead [2]int) ([]string, int) {
	//fmt.Print("gen_paths(", source, ", ", target, ", ", dead, ")\n")
	var dist [2]int
	dist = [2]int {target[0] - source[0], target[1] - source[1]}
	steps := abs(dist[0]) + abs(dist[1])
	verticals := abs(dist[1])
	var paths = make([]string, ncr(steps, verticals))
	var vsign, hsign int
	var vstr, hstr string
	if dist[0] > 0 { hsign = 1; hstr = ">" } else { hsign = -1; hstr = "<" }
	if dist[1] > 0 { vsign = 1; vstr = "v" } else { vsign = -1; vstr = "^" }
	if verticals == 0 {
		paths[0] = repeat(hstr, (steps - verticals))
		return paths, 1
	} else if steps - verticals == 0 {
		paths[0] = repeat(vstr, verticals)
		return paths, 1
	} else {
		var idx = 0
		for i := 0; i <= verticals; i++ {
			prefix := repeat(vstr, i) + hstr
			new_source := [2]int {source[0] + hsign, source[1] + vsign * i}
			if new_source[1] == dead[1] && (source[0] == dead[0] || new_source[0] == dead[0]) {
				continue
			}
			new_paths, l := gen_paths(new_source, target, dead)
			for i := 0; i < l; i++ {
				paths[idx] = prefix + new_paths[i]
				idx++
			}
		}
		return paths, idx
	}
}

func shortest_outer_path_for_button_press(start_loc, end_loc, dead_loc [2]int, key_lookup []map[string][2]int, cache [][3][4][3][4]int64) int64 {
	fmt.Print("shortest_outer_path_for_button_press(", start_loc, ", ", end_loc, ", ", len(key_lookup), ")\n")
	if cache[0][start_loc[0]][start_loc[1]][end_loc[0]][end_loc[1]] > int64(0) {
		fmt.Print("shortest_outer_path_for_button_press(", start_loc, ", ", end_loc, ", ", len(key_lookup), ") -cached> ", cache[0][start_loc[0]][start_loc[1]][end_loc[0]][end_loc[1]], "\n")
		return cache[0][start_loc[0]][start_loc[1]][end_loc[0]][end_loc[1]]
	}
	paths, l := gen_paths(start_loc, end_loc, dead_loc)
	//fmt.Print("gen_paths(", locs[0], ", ", key_lookup[0][dest], ") -> ", paths, "\n")
	var slen int64 = 0;
	if len(key_lookup) == 0 {
		for i := 0; i < l; i++ {
			if slen == 0 || int64(len(paths[i])) < slen {
				slen = int64(len(paths[i]))
			}
		}
		slen += 1
	} else {
		for i := 0; i < l; i++ {
			inner_path := paths[i] + "A"
			best := shortest_outer_path_for_inner_path(key_lookup, inner_path, cache)
			if slen == 0 || best < slen {
				slen = best
			}
		}
	}
	cache[0][start_loc[0]][start_loc[1]][end_loc[0]][end_loc[1]] = slen
	fmt.Print("shortest_outer_path_for_button_press(", start_loc, ", ", end_loc, ", ", len(key_lookup), ") -computed> ", cache[0][start_loc[0]][start_loc[1]][end_loc[0]][end_loc[1]], "\n")
	return slen
}

func shortest_outer_path_for_inner_path(key_lookup []map[string][2]int, path string, cache [][3][4][3][4]int64) int64 {
	//fmt.Print("shortest_outer_path_for_inner_path(", len(key_lookup), ", ", path, ")\n")
	outer_path_len := int64(0)
	start_loc := key_lookup[0]["A"]
	dead_loc := key_lookup[0]["dead"]
	for j := 0; j < len(path); j++ {
		//fmt.Print(path[j:j+1], "\n")
		//fmt.Print(key_lookup[0], "\n")
		new_loc := key_lookup[0][path[j:j+1]]
		outer_path_len += shortest_outer_path_for_button_press(start_loc, new_loc, dead_loc, key_lookup[1:], cache[1:])
		start_loc = new_loc
	}
	//fmt.Print("shortest_outer_path_for_inner_path(", len(key_lookup), ", ", path, ") -> ", outer_path, "\n")
	return outer_path_len
}
