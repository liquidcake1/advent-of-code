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
import java.util.Set;
import java.util.HashSet;

public class SolutionSearch {
	public static class Particle {
		public double[] pos;
		public double[] velocity;
		public Particle(List<Long> inpos, List<Long> invelocity) {
			pos = inpos.stream().mapToDouble(i -> i).toArray();
			velocity = invelocity.stream().mapToDouble(i -> i).toArray();
		}
		public Particle(double inpos[], double invelocity[]) {
			pos = inpos;
			velocity = invelocity;
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
			if (y_intercept < 0) {
				return null;
			}
			double x_intercept = (other.pos[0] - this.pos[0] + y_intercept * other.velocity[0]) / this.velocity[0];
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
	public static void swap_rows(double in[][], int row1_i, int row2_i) {
		double tmp[] = in[row1_i];
		in[row1_i] = in[row2_i];
		in[row2_i] = tmp;
	}
	public static void multiply_row(double in[][], int row_i, double x) {
		double row[] = in[row_i];
		for(int i=0; i<row.length; i++) {
			row[i] *= x;
		}
	}
	public static void add_row(double in[][], int row_target_i, int row_source_i, double mul) {
		double row_source[] = in[row_source_i];
		double row_target[] = in[row_target_i];
		for(int i=0; i<row_source.length; i++) {
			row_target[i] += row_source[i] * mul;
		}
	}
	public static void upper_echelon(double in[][]) {
		int row=0;
		int irow;
		for(int col=0; col<in[0].length - 1 && row < in.length; col++) {
			// Find the first row with nonzero col, swap it to row.
			for(int row_s=row; row_s<in.length; row_s++) {
				if (Math.abs(in[row_s][col]) > 1.0e-15) {
					swap_rows(in, row_s, row);
					break;
				} else {
					in[row_s][col] = 0;
				}
			}
			if (in[row][col] == 0) {
				// There is no such row.
				continue;
			}
			// Renormalise
			multiply_row(in, row, 1.0 / in[row][col]);
			//in[row][col] = 1.0;
			// Eliminate from all other rows
			for(int row_s=0; row_s<in.length; row_s++) {
				if (row_s == row) continue;
				add_row(in, row_s, row, -in[row_s][col]);
				in[row_s][col] = 0;
			}
			row += 1;
		}
		/*
		System.out.println("Alleged upper echelon:");
		for(irow=0; irow<in.length; irow++) {
			System.out.println(Arrays.toString(in[irow]));
		}
		//*/
	}
	public static class NoSolution extends Exception {}
	public static Double[] solve(double in[][]) throws NoSolution {
		upper_echelon(in);
		Double ret[] = new Double[in[0].length - 1];
		if (in.length > in[0].length - 1) {
			if (Math.abs(in[in[0].length - 1][in[0].length - 1]) > 0.01) { // The math errors are strong with this one.
				// Quickie no solution
				throw new NoSolution();
			}
		}
		int row=0;
		for(int col=0; col<ret.length && row<in.length; col++) {
			if (in[row][col] == 0) {
				// Multiple solutions.
				ret[col] = null;
			} else {
				boolean known = true;
				for (int nextcol=col+1; nextcol<ret.length; nextcol++) {
					if (Math.abs(in[row][nextcol]) > 1e-6) {
						// Multiple solutions. We'll get the free variables later.
						ret[col] = null;
						known = false;
						break;
					}
				}
				if (known) {
					ret[col] = -in[row][ret.length];
				}
				row++;
			}
		}
		if (row < in.length && Math.abs(in[row][ret.length]) > 0.01) {
			throw new NoSolution();
		}
		return ret;
	}
	/*public static class Solution {
		public Double[] solvec;
		public double[][] matrix;
	}*/
	static double[][] gen_matrix(List<Particle> particles, int investigated_points, int[] stone_vel_guess, int investigated_coords) {
		double matrix[][] = new double[investigated_points * investigated_coords][investigated_points + investigated_coords + 1];
		for (int coord = 0; coord<investigated_coords; coord++) {
			for (int parti=0; parti<investigated_points; parti++) {
				// x[parti] + t[parti] * xv[parti] = stonex + T[parti] * stonevx
				// -1 * stoneX + (xv[parti] - stonevx) * T[parti]    + x[parti]                  = 0
				// [coord]                               [2 + parti] + [2 + investigated_points]
				matrix[parti * investigated_coords + coord][coord] = -1;
				matrix[parti * investigated_coords + coord][investigated_coords + parti] = particles.get(parti).velocity[coord] - stone_vel_guess[coord]; // t[parti] * stone_vel_guess[coord]
				matrix[parti * investigated_coords + coord][investigated_coords + investigated_points] = particles.get(parti).pos[coord];
			}
		}
		return matrix;
	}
	public static void main(String[] args) throws Exception {
	        Path path = Paths.get(args[0]);
		List<String> lines = Files.lines(path).collect(Collectors.toList());
		Vector<Particle> particles = new Vector();
		for(String line: lines) {
			List<String> split = Arrays.stream(line.split(" @ ")).collect(Collectors.toList());
			List<Long> pos = Arrays.stream(split.get(0).split(", ")).map(x -> Long.parseLong(x)).collect(Collectors.toList());
			List<Long> velocity = Arrays.stream(split.get(1).split(", ")).map(x -> Long.parseLong(x.strip())).collect(Collectors.toList());
			particles.add(new Particle(pos, velocity));
		}
		int hits1 = 0;
		int hits2 = 0;
		for(Particle p1: particles) {
			for(Particle p2: particles) {
				if (p1 == p2) continue;
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
		/*
		double matrix[][] = new double[3 * lines.length][7 + lines.length];
		// Col 1-3 is start pos
		// Col 4-6 is start vel
		// Col n - 6 is intercept time
		for(int i=0; i<points.length; i++) {
			matrix[3*i][0] = 1;
		}*/
		// OK, let's gradient descent using total z distance. NOPE! LOL!!
		// So, instead let's fix stone.pos[0] = 0, stone.vel[0] = 1.
		// We're assuming that stone.vel[0] is nonzero.
		// We can solve for t in each equation, then find stone.pos[1:] and stone.vel[1:]
		// Now we just need to find an integer solution on that line
		int investigated_points = 3;
		// cols are stone.pos[0], stone.pos[1], t0, t1, const
		// rows are resolving point N, coord I

		boolean debug = false;
		int investigated = 0;
		for(int svx=Integer.parseInt(args[1]); svx<=Integer.parseInt(args[2]); svx++) {
			System.out.println("Considering vx =" + svx);
			int stone_vel_guess[] = {svx, 0};
			String skip_reason = null;
			try {
				double matrix[][] = gen_matrix(particles, Math.min(10, particles.size()), stone_vel_guess, 1);
				Double test_result[] = solve(matrix);
				if (Math.abs(Math.round(matrix[0][matrix[0].length-1]) - matrix[0][matrix[0].length-1]) > 0.001) {
					skip_reason = "it has non-integer multiple of last var";
				}
				if (test_result[0] != null && Math.abs(Math.round(test_result[0]) - test_result[0]) > 0.001) {
					skip_reason = "it is non-integer excluding Y";
					continue;
				} else {
					System.out.println("Amenable x " + svx + " " + Arrays.toString(test_result));
				}
				int zero_count = 0;
				final Set<Long> set = new HashSet<>();
				for (int i=0; i<investigated_points; i++) {
					Double rd = test_result[1 + i];
					if (rd == null) continue;
					double r = rd;
					if (Math.abs(r) < 0.0001) {
						zero_count += 1;
					}
					double xint = r * svx;
					long rounded = Math.round(xint);
					if (Math.abs(rounded - xint) > 0.0001) {
						skip_reason = "it produces a non-integer intersection";
						break;
					}
					if (r < -0.0001) {
						skip_reason = "it produces an intersection in the past";
						break;
					}
					if (!set.add(rounded)) {
						skip_reason = "it has two particles with the same intersection" + Arrays.toString(test_result);
						break;
					}
				}

				if (zero_count > 1) {
					skip_reason = "it requires multiple zeros";
				}
			} catch (NoSolution e) {
				skip_reason = "it is non-amenable excluding Y";
			}
			if (skip_reason != null) {
				if (debug) System.out.println("Skipping " + svx + " as " + skip_reason);
				continue;
			}
			investigated += 1;
			for(int svy=Integer.parseInt(args[3]); svy<=Integer.parseInt(args[4]); svy++) {
				if (debug) System.out.println("Considering vy=" + svy);
				stone_vel_guess[1] = svy;
				Double[] result = null;
				try {
					double matrix[][] = gen_matrix(particles, 2, stone_vel_guess, 2);
					result = solve(matrix);
				} catch (NoSolution e) {
					if (debug) System.out.println("Skipped non-amenable result after 2");
					continue;
				}
				if (result == null) {
					if (debug) System.out.println("Skipped dead result after 2");
					continue;
				}
				try {
					double matrix[][] = gen_matrix(particles, investigated_points, stone_vel_guess, 2);
					result = solve(matrix);
				} catch (NoSolution e) {
					if (debug) System.out.println("Skipped no solution result " + result);
					continue;
				}
				if (result == null) {
					if (debug) System.out.println("Skipped dead result after " + investigated_points);
					continue;
				}
				if (svx == -3 && svy == 1) {
					System.out.println("Yep solved.");
				}
				System.out.println("Solved: " + svx + " " + svy + " " + Arrays.toString(result));
				// We've got vx and vy. Just need to work out the rest.
			}
		}
		System.out.println("Investigated: " + investigated);
		Particle firstpart = particles.get(0);
		for(Particle p: particles) {
			if (p != firstpart) continue;
			if (p == firstpart) continue;
			if (p.velocity[0] == -3) continue; // Collides everywhere!
			System.out.println("First particle" + firstpart);
			System.out.println("Secnd particle" + p);
			double t0 = (firstpart.pos[0] - 24) / (-3 - firstpart.velocity[0]);
			double t1 = (p.pos[0] - 24) / (-3 - p.velocity[0]);
			double stone_vely = (p.pos[1] + t1 * p.velocity[1] - firstpart.pos[1] - t0 * firstpart.velocity[1]) / (t1 - t0);
			double stone_velz = (p.pos[2] + t1 * p.velocity[2] - firstpart.pos[2] - t0 * firstpart.velocity[2]) / (t1 - t0);
			double stone_posy = firstpart.pos[1] + t0 * firstpart.velocity[1] - t0 * stone_vely;
			double stone_posz = firstpart.pos[2] + t0 * firstpart.velocity[2] - t0 * stone_velz;
			System.out.println(firstpart.pos[0] + t0 * firstpart.velocity[0]);
			System.out.println(24 + -3 * t0);
			System.out.println(firstpart.pos[1] + t0 * firstpart.velocity[1]);
			System.out.println(stone_vely * t0 + stone_posy);
			System.out.println(firstpart.pos[2] + t0 * firstpart.velocity[2]);
			System.out.println(stone_velz * t0 + stone_posz);
			System.out.println(p.pos[0] + t1 * p.velocity[0]);
			System.out.println(24 * -3 * t1);
			System.out.println(p.pos[1] + t1 * p.velocity[1]);
			System.out.println(stone_vely * t1 + stone_posy);
			System.out.println(p.pos[2] + t1 * p.velocity[2]);
			System.out.println(stone_velz * t1 + stone_posz);
			double stone_pos[] = {24, stone_posy, stone_posz};
			double stone_vel[] = {-3, stone_vely, stone_velz};
			Particle stone = new Particle(stone_pos, stone_vel);
			System.out.println(stone);
		}
	}
}
