use std::env;
use std::fs;
use std::collections::HashSet;
use std::convert::TryInto;

fn main() {
    let args: Vec<String> = env::args().collect();
    println!("{:?}", args);
    let contents = fs::read_to_string(&args[1])
        .expect("Something went wrong reading the file");

    let lines: Vec<&str> = contents.split("\n").collect();
    println!("With text:\n{:?}", lines[0].chars().nth(0).expect("Oops"));
    // Find S
    let mut points: HashSet<(i16, i16)> = HashSet::new();
    for y in 0..lines.len() {
        match lines[y].find("S") {
            Some(x) => points.insert((y.try_into().unwrap(), x.try_into().unwrap())),
            _ => false,
        };
    }
    println!("Points: {:?}", points);
    // Needed to silence moans about comparisons with usize below.
    let mut ymax: i16 = lines.len().try_into().unwrap();
    let mut xmax: i16 = lines[0].len().try_into().unwrap();
    ymax -= 1;
    println!("{} {}", xmax, ymax);
    for step in 0..64 {
        let mut newPoints: HashSet<(i16, i16)> = HashSet::new();
        for prp in &points {
            // Trying to iterate (x, y) seems to make x, y into &i16?
            let x: i16 = prp.0;
            let y: i16 = prp.1;
            for pr in [(-1, 0), (1, 0), (0, -1), (0, 1)].iter() {
                let yd: i16 = pr.1;
                if yd > 0 && ymax == y || yd < 0 && y == 0 {
                    continue;
                }
                let ny : usize = (y+yd).try_into().unwrap();
                let xd: i16 = pr.0;
                if xd > 0 && xmax <= x || xd < 0 && x == 0 {
                    continue;
                }
                let nx : usize = (x+xd).try_into().unwrap();
                //println!("{} {} {:?} {:?}", nx, ny, pr, step);
                let target: char = lines[ny].chars().nth(nx).unwrap();
                if target == '.' || target == 'S' {
                    println!("({}, {}) -> ({}, {})", x, y, nx, ny);
                    newPoints.insert((nx.try_into().unwrap(), ny.try_into().unwrap()));
                } else {
                    println!("({}, {}) nope ({}, {}) {}", x, y, nx, ny, lines[ny].chars().nth(nx).unwrap());
                }
            }
        }
        points = newPoints;
        println!("{:?}", points);
        println!("{}", points.len());
    }
}
