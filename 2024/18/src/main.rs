use std::env;
use std::fs;
use std::cmp::Ordering;
use std::collections::BinaryHeap;
use std::collections::VecDeque;

#[derive(Copy, Clone, Eq, PartialEq)]
struct State {
    path_len: usize,
    position: (usize, usize),
}

impl Ord for State {
    fn cmp(&self, other: &Self) -> Ordering {
        // Notice that the we flip the ordering on costs.
        // In case of a tie we compare positions - this step is necessary
        // to make implementations of `PartialEq` and `Ord` consistent.
        other.path_len.cmp(&self.path_len)
            .then_with(|| self.position.cmp(&other.position))
    }
}
impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    println!("{:?}", args);
    let contents = fs::read_to_string(&args[1])
        .expect("Something went wrong reading the file");

    let lines: Vec<&str> = contents.lines().collect();
    let coords: Vec<(usize, usize)> = lines.iter().map(parse_line).collect();
    fn parse_line(line: &&str) -> (usize, usize) {
        let ints: Vec<usize> = line.split(",").map(|x| x.parse::<usize>().unwrap()).collect();
        (ints[0], ints[1])
    }
        
    //println!("Lines:\n{:?}", lines);
    //println!("Coords:\n{:?}", coords);
    let apply_count = if args[1] == "sample" { 12 } else { 3009 };
    println!("{}", apply_count);
    let coords_to_apply = &coords[..apply_count];
    let max_x: usize = coords.iter().map(|x| x.0).reduce(usize::max).unwrap().try_into().unwrap();
    let max_y: usize = coords.iter().map(|x| x.1).reduce(usize::max).unwrap().try_into().unwrap();
    let mut grid = vec![vec![true; max_y + 1]; max_x + 1];
    for (x, y) in coords_to_apply {
        grid[*x][*y] = false;
        println!("{},{}", x, y);
    }
    println!("{} {}", max_x, max_y);
    for y in 0..max_y+1 {
        for x in 0..max_x+1 {
            print!("{}", if grid[x][y] {"."} else {"#"});
        }
        println!("");
    }
    //println!("Coords:\n{:?}", coords_to_apply);

    let mut bests = vec![vec![max_x * max_y; max_y + 1]; max_x + 1];
    const DIRS: [(i32, i32); 4] = [(1, 0), (0, 1), (-1, 0), (0, -1)];
    fn dijk(bests: &mut Vec<Vec<usize>>, grid: &Vec<Vec<bool>>) {
        let mut heap = BinaryHeap::new();
        heap.push(State { path_len: 0, position: (0, 0) });
        while let Some(State { path_len, position }) = heap.pop() {
            if path_len >= bests[position.0][position.1] {
                continue;
            }
            bests[position.0][position.1] = path_len;
            for dir in DIRS {
                let newx: i32 = position.0 as i32 + dir.0;
                let newy: i32 = position.1 as i32 + dir.1;
                if 0 <= newx && newx < bests.len().try_into().unwrap() &&
                    0 <= newy && newy < bests[0].len().try_into().unwrap() &&
                        grid[position.0][position.1]
                        {
                            heap.push(State{ path_len: path_len + 1, position: (newx.try_into().unwrap(), newy.try_into().unwrap())});
                        }
            }
        }
    }
    dijk(&mut bests, &grid);
    println!("{}", bests[max_x][max_y]);
    
    let mut grid = vec![vec![false; max_y + 1]; max_x + 1];
    let queue = VecDeque::from([(max_x, max_y)]);
    bests = vec![vec![max_x * max_y; max_y + 1]; max_x + 1];
    // Compute the best route.
    // Add blockers until one hits best route.
    // Redo dijk plus best route.
    // Repeat until no best route. That was the killer.
}
