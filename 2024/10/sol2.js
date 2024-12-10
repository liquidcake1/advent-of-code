var stdin = new java.io.BufferedReader(new java.io.InputStreamReader(java.lang.System['in']))
var lines = [];
var cache = [];
var cache2 = [];
var cachei = [];
while(true) {
	var line = stdin.readLine();
	if (!line) break;
	var numbers = [];
	var cachel = [];
	var cache2l = [];
	var cacheil = [];
	for(var i = 0; i < line.length(); i++) {
		numbers.push(line.charAt(i) - 48);
		cachel.push([]);
		cacheil.push(0);
		cache2l.push(0);
	}
	lines.push(numbers);
	cache.push(cachel);
	cachei.push(cacheil);
	cache2.push(cache2l);
}
print(lines[4][3]);
var dirs = [[-1, 0], [1, 0], [0, -1], [0, 1]];
var total = 0;
var totalr = 0;
for(var height=9; height>=0; height--) {
	for(var row=0; row<lines.length; row++) {
		for(var col=0; col<lines.length; col++) {
			if(lines[row][col] == height) {
				var peaks = new java.util.HashSet();
				var rating = 0;
				if (height == 9) {
					peaks.add(row+","+col);
					rating = 1;
				}
				for(var i=0; i<4; i++) {
					var newcol = col + dirs[i][0];
					var newrow = row + dirs[i][1];
					if (newcol < 0 ||newrow < 0 || newcol >= lines.length || newrow >= lines.length) continue;
					if(lines[newrow][newcol] != height + 1) continue;
					for(var j=0; j<cache[newrow][newcol].length; j++) {
						peaks.add(cache[newrow][newcol][j]);
					}
					rating += cache2[newrow][newcol];
				}
				cache[row][col] = peaks.toArray();
				cachei[row][col] = peaks.size();
				cache2[row][col] = rating;
				if (height == 0) {
					total += peaks.size();
					totalr += rating;
				}
			}
		}
		print(cachei[row]);
	}
	print();
}
print(total);
print(totalr);
