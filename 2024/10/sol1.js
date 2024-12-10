var stdin = new java.io.BufferedReader(new java.io.InputStreamReader(java.lang.System['in']))
var lines = [];
var cache = [];
var cachei = [];
while(true) {
	var line = stdin.readLine();
	if (!line) break;
	var numbers = [];
	var cachel = [];
	var cacheil = [];
	for(var i = 0; i < line.length(); i++) {
		numbers.push(line.charAt(i) - 48);
		cachel.push([]);
		cacheil.push(0);
	}
	lines.push(numbers);
	cache.push(cachel);
	cachei.push(cacheil);
}
print(lines[4][3]);
var dirs = [[-1, 0], [1, 0], [0, -1], [0, 1]];
var total = 0;
for(var height=9; height>=0; height--) {
	for(var row=0; row<lines.length; row++) {
		for(var col=0; col<lines.length; col++) {
			if(lines[row][col] == height) {
				var peaks = new java.util.HashSet();
				if (height == 9) peaks.add(row+","+col);
				for(var i=0; i<4; i++) {
					var newcol = col + dirs[i][0];
					var newrow = row + dirs[i][1];
					if (newcol < 0 ||newrow < 0 || newcol >= lines.length || newrow >= lines.length) continue;
					if(lines[newrow][newcol] != height + 1) continue;
					for(var j=0; j<cache[newrow][newcol].length; j++) {
						peaks.add(cache[newrow][newcol][j]);
					}
				}
				cache[row][col] = peaks.toArray();
				cachei[row][col] = peaks.size();
				if (height == 0) {
					total += peaks.size();
				}
			}
		}
		print(cachei[row]);
	}
	print();
}
print(total);
