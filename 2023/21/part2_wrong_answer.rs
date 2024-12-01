use std::env;
use std::fs;
use std::collections::HashSet;
use std::convert::TryInto;

fn main() {
    let args: Vec<String> = env::args().collect();
    let contents = fs::read_to_string(&args[1])
        .expect("Something went wrong reading the file");

    let lines: Vec<Vec<char>> = contents.split("\n").map(|v| v.chars().collect()).collect();
    //println!("With text:\n{:?}", lines[0].chars().nth(0).expect("Oops"));
    // Find S
    //println!("Points: {:?}", points);
    // Needed to silence moans about comparisons with usize below.
    let mut ymax: i64 = lines.len().try_into().unwrap();
    let xmax: i64 = lines[0].len().try_into().unwrap();
    ymax -= 1;
    let xmid: i64 = xmax / 2;
    let ymid: i64 = ymax / 2;
    // Needed for part 2. No need to find S if we know where it is.
    assert!(lines[ymid as usize][xmid as usize] == 'S');

    assert!(ymax % 2 == 1);
    assert!(xmax == ymax);
    // Can't apparently use an array for these?
    let mut midedge_counts: Vec<i64> = Vec::new();
    let mut corner_counts: Vec<i64> = Vec::new();
    let mut s_counts: Vec<i64> = Vec::new();
    for _ in 0..xmax * 2 {
        midedge_counts.push(0);
        corner_counts.push(0);
        s_counts.push(0);
    }
    for thing in &mut[
            (&mut midedge_counts, &vec![(0, xmid), (ymax - 1, xmid), (ymid, 0), (ymid, ymax - 1)]),
            (&mut corner_counts, &vec![(0, 0), (0, xmax - 1), (ymax - 1, 0), (ymax - 1, xmax - 1)]),
            (&mut s_counts, &vec![(xmid, xmid)]),
    ] {
        let mut counts = &mut thing.0;
        for start in thing.1 {
            let mut points: HashSet<(i64, i64)> = HashSet::new();
            points.insert((start.0, start.1));
            let mut last_count: usize = 0;
            let mut last_last_count: usize = 0;
            let mut skip = false;
            for count in 0..xmax * 2 {
                if skip {
                    println!("{:?} {:?} SKIP {}", start, count, last_count);
                    counts[count as usize] += last_count as i64;
                    let tmp = last_count;
                    last_count = last_last_count;
                    last_last_count = tmp;
                    continue
                }
                counts[count as usize] += points.len() as i64;
                println!("{:?} {:?} {}", start, count, points.len());
                let mut new_points: HashSet<(i64, i64)> = HashSet::new();
                for prp in &points {
                    // Trying to iterate (x, y) seems to make x, y into &i64?
                    let x: i64 = prp.0;
                    let y: i64 = prp.1;
                    for pr in [(-1, 0), (1, 0), (0, -1), (0, 1)].iter() {
                        let yd: i64 = pr.1;
                        if yd > 0 && y == ymax - 1 || yd < 0 && y == 0 {
                            continue;
                        }
                        let ny : usize = (y+yd).try_into().unwrap();
                        let xd: i64 = pr.0;
                        if xd > 0 && x == xmax - 1 || xd < 0 && x == 0 {
                            continue;
                        }
                        let nx : usize = (x+xd).try_into().unwrap();
                        //println!("{} {} {:?}", nx, ny, pr);
                        let target: char = lines[ny][nx];
                        if target == '.' || target == 'S' {
                            //println!("({}, {}) -> ({}, {})", x, y, nx, ny);
                            new_points.insert((nx as i64, ny as i64));
                        } else {
                            //println!("({}, {}) nope ({}, {}) {}", x, y, nx, ny, lines[ny][nx]);
                        }
                    }
                }
                if skip || last_last_count == points.len() {
                    skip = true;
                } else {
                    last_last_count = last_count;
                    last_count = points.len();
                }
                points = new_points;
            }
        }
    }
    if xmax == 11 {
        println!("Part 1: {}", s_counts[6]);
    } else {
        println!("Part 1: {}", s_counts[64]);
    }
    // PART 2
    // Observations:
    // * The central path (L/R/U/D) is clear, as are the 4 edges, so propagation over copies is at
    // the maximum speed; there are no weird wrappings.
    // * There's also a very clear diamond, but I doubt this does anyting.
    // * This also means that propagation is not dependent on garden shape or history on any
    // neighbour -- just the entry direction. In fact, the S is always in the centre, so each copy
    // will be entered from both S-oriented diagonals together.
    // * Once a garden is "full", it'll alternate between two values -- odds and evens.
    // * We're at an odd width, which means both "full" values will be present.
    // * There are probably relatively few possible states, as there's an explore from S, and from
    // each corner.
    // * The "full" time can be much higher than the width, but for these inputs it's doubtful that
    // it's any higher at all as the blockers are not dense.
    
    // Algorithm:
    // * For each 4 corners, and S, and the middle of each side, compute the counts at each step until stabilisation.
    // * The number of full even (N even) grids is 1 + 4 + 25 + ... + (N/W)**2
    // * The number of full odd  (N even) grids is 1 + 4 + 25 + ... + ((N-1)/W)**2
    // * The number of each corner grid (on each diagonal) is (N/W) - 1.
    // * The number of each edge grid is exactly 1.
    // * The progress through each corner grid is N%W.
    // * The progress through each edge grid is (N-W/2)%W.
    // THERE ARE "LATE" and "EARLY" corner and edge grids.
    // Examples (TR only, W=11):
    //
    //        2D
    //       13D  7C
    //       24d 18C  7C
    //       30s 24l 13L  2L 
    //
    //        1D
    //       12D  6C
    //       23d 17C  6C
    //       34d 28c 17C  6C
    //       40s 34l 23l 12L 1L
    //
    let steps_into_s = 26501365;

    let s_index = if steps_into_s >= xmax * 2 { xmax * 2 - 2 + (steps_into_s % 2) } else { steps_into_s };
    let s_squares = s_counts[s_index as usize];

    let steps_into_midedge = steps_into_s - xmid - 1;
    let midedge_index_outer = steps_into_midedge % xmax;
    let midedge_index_inner = xmax + midedge_index_outer;
    let gardens_to_midedge = steps_into_midedge / xmax as i64;
    let midedge_outers = if gardens_to_midedge >= 0 { 1 } else { 0 };
    let midedge_inners = if gardens_to_midedge >= 1 { 1 } else { 0 };
    let midedge_fulls = std::cmp::max(gardens_to_midedge - 2, 0);
    let midedge_full_0_parity = steps_into_midedge % 2;
    let midedge_index_full_0 = xmax * 2 - 2 + midedge_full_0_parity;
    let midedge_index_full_1 = xmax * 2 - 2 + 1 - midedge_full_0_parity;
    let midedge_fulls_0 = (midedge_fulls + 1) / 2 as i64;
    let midedge_fulls_1 = midedge_fulls / 2 as i64;
    let midedge_squares = midedge_outers * midedge_counts[midedge_index_outer as usize] +
            midedge_inners * midedge_counts[midedge_index_inner as usize] +
            midedge_fulls_0 * midedge_counts[midedge_index_full_0 as usize] +
            midedge_fulls_1 * midedge_counts[midedge_index_full_1 as usize];

    let steps_into_corner = steps_into_s - xmax - 1;
    let corner_index_outer = std::cmp::max(0, steps_into_corner % xmax);
    let corner_index_inner = xmax + corner_index_outer;
    let gardens_to_corner = steps_into_corner / xmax as i64;
    let corner_full_parity = steps_into_corner % 2;
    let corner_index_full = xmax * 2 - 2 + corner_full_parity;
    let corner_outers = std::cmp::max(gardens_to_corner, 0);
    let corner_inners = std::cmp::max(gardens_to_corner - 1, 0);
    let corner_fulls_len = std::cmp::max(gardens_to_corner - 2, 0);
    let corner_fulls = corner_fulls_len * (corner_fulls_len - 1) / 2 as i64;
    let corner_squares = corner_outers * corner_counts[corner_index_outer as usize] +
            corner_inners * corner_counts[corner_index_inner as usize] +
            corner_fulls * corner_counts[corner_index_full as usize];

    let total_squares = s_squares + midedge_squares + corner_squares;

    println!("Part 2: {}", total_squares);
    println!("Part 2 breakdown: s_index={}, s_squares={}", s_index, s_squares);
    println!("Part 2 breakdown: midedge_index_outer={}, midedge_outers={}, midedge_outer_square={}", midedge_index_outer, midedge_outers, midedge_counts[midedge_index_outer as usize]);
}
