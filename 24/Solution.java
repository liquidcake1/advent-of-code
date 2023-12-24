import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.stream.Stream;
import java.util.stream.Collectors;
import java.util.List;
import java.util.Arrays;
import java.lang.Integer;
import java.util.Vector;

public class Solution {
	public static class Particle {
		public double[] pos;
		public double[] velocity;
		public Particle(List<Long> inpos, List<Long> invelocity) {
			pos = inpos.stream().mapToDouble(i -> i).toArray();
			velocity = invelocity.stream().mapToDouble(i -> i).toArray();
		}
		public String toString() {
			return "Particle<" + Arrays.toString(pos) + ", " + Arrays.toString(velocity) + ">";
		}
		public double[] intersects(Particle other) {
			/* x1 + x * x1d = y1 + y * y1d
			 * x = (y1 - x1 + y * y1d) / x1d
			 * x2 + ((y1 - x1 + y * y1d) / x1d) * x2d = y2 + y * y2d
			 * y * y1d / x1d * x2d - y * y2d = y2 - x2 - (y1 - x1) / x1d * x2d
			 * */
			if (this.velocity[0] * other.velocity[1] - this.velocity[1] * other.velocity[0] == 0) {
				// no intersect on first two co-ords
				return null;
			}
			double y_intercept = (other.pos[1] - this.pos[1] - (other.pos[0] - this.pos[0]) / this.velocity[0] * this.velocity[1]) / (other.velocity[0] / this.velocity[0] * this.velocity[1] - other.velocity[1]);
			System.out.println(y_intercept);
			if (y_intercept < 0) {
				return null;
			}
			double x_intercept = (other.pos[0] - this.pos[0] + y_intercept * other.velocity[0]) / this.velocity[0];
			System.out.println(x_intercept);
			if (x_intercept < 0) {
				return null;
			}
			double intersect[] = {
				y_intercept * other.velocity[0] + other.pos[0],
				y_intercept * other.velocity[1] + other.pos[1],
				y_intercept * other.velocity[2] + other.pos[2]
			};
			return intersect;
		}
	}
	public static void main(String[] args) throws Exception {
	        Path path = Paths.get(args[0]);
		List<String> lines = Files.lines(path).collect(Collectors.toList());
		System.out.println(lines);
		Vector<Particle> points = new Vector();
		for(String line: lines) {
			List<String> split = Arrays.stream(line.split(" @ ")).collect(Collectors.toList());
			List<Long> pos = Arrays.stream(split.get(0).split(", ")).map(x -> Long.parseLong(x)).collect(Collectors.toList());
			System.out.println(pos);
			List<Long> velocity = Arrays.stream(split.get(1).split(", ")).map(x -> Long.parseLong(x.strip())).collect(Collectors.toList());
			System.out.println(velocity);
			points.add(new Particle(pos, velocity));
		}
		System.out.println(points);
		int hits1 = 0;
		int hits2 = 0;
		for(Particle p1: points) {
			for(Particle p2: points) {
				if (p1 == p2) continue;
				System.out.println(p1);
				System.out.println(p2);
				System.out.println(Arrays.toString(p1.intersects(p2)));
				double intercept[] = p1.intersects(p2);
				if (intercept == null) continue;
				if (intercept[0] <= 27 && intercept[0] >= 7 && intercept[1] <= 27 && intercept[0] >= 7) {
					hits1 += 1;
				}
				if (intercept[0] <= 400000000000000.0 && intercept[0] >= 200000000000000.0 && intercept[1] <= 400000000000000.0 && intercept[1] >= 200000000000000.0) {
					hits2 += 1;
				}
			}
		}
		System.out.println("Sample answer part 1: " + hits1 / 2);
		// 17454 too high
		System.out.println("Real answer part 1: " + hits2 / 2);
	}
}
