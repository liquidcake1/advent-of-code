#include <stdio.h>
#include <stdlib.h>

void printb(char **buf, int xs, int ys) {
	printf("%03i %03i\n", ys, xs);
	for(int y=0; y<ys; y++) {
		printf("%03i ", y);
		for(int x=0; x<xs; x++) {
			putchar(buf[x][y]);
		}
		putchar('\n');
	}
	putchar('\n');
}

void moverocks(char **buf, int xs, int ys, int xd, int yd) {
	int xstart = 0, ystart = 0, xadd = 1, yadd = 1;
	if (xd > 0) {
		xstart = xs-1;
		xadd = -1;
	} else if (xd < 0) {
	} else if (yd > 0) {
		ystart = ys-1;
		yadd = -1;
	} else if (yd < 0) {
	} else {
	}
	for(int x=xstart; x<xs && x>=0; x+=xadd) {
		for (int y=ystart; y<ys && y>=0; y+=yadd) {
			if (buf[x][y] == '.') {
				for (int rx=x, ry=y; ry<ys && rx<xs && ry>=0 && rx>=0 && buf[rx][ry] != '#'; rx-=xd, ry-=yd) {
					if (buf[rx][ry] == 'O') {
						buf[rx][ry] = '.';
						buf[x][y] = 'O';
						break;
					}
				}
			}
			//printf("After %3i %3i %03i %03i\n", x, y, xd, yd);
			//printb(buf, xs, ys);
		}
	}
}

void cycle(char **buf, int xs, int ys) {
	moverocks(buf, xs, ys, 0, -1);
	moverocks(buf, xs, ys, -1, 0);
	moverocks(buf, xs, ys, 0, 1);
	moverocks(buf, xs, ys, 1, 0);
}

void copybuf(char **buf, char *store, int xs, int ys) {
	for(int y=0; y<ys; y++) {
		for(int x=0; x<xs; x++) {
			store[y*xs+x] = buf[x][y];
		}
	}
}

int checkbuf(char *first, char *second, int size) {
	for(int i=0; i<size; i++) {
		if (first[i] != second[i]) {
			return 0;
		}
	}
	return 1;
}

int findbuf(char *needle, char *haystack, int size) {
	for(; haystack<needle; haystack += size) {
		if (checkbuf(needle, haystack, size)) {
			return (needle - haystack) / size;
		}
	}
	return 0;
}

int load(char **buf, int xs, int ys) {
	int load = 0;
	for(int y=0; y<ys; y++) {
		for(int x=0; x<xs; x++) {
			if (buf[x][y] == 'O') {
				load += ys - y;
			}
		}
	}
	return load;
}

int main(int argv, char **argc) {
	// Bit ugly because I flipped from using char ** to char * for the
	// cycle code as I thought the cycles would be really long and I'd
	// need to save time!
	char *buf[1000];
	for(int i=0; i<1000; i++) {
		buf[i] = malloc(1000);
	}
	int in;
	int x = 0, y = 0, xs, ys;
	while((in = getchar()) != EOF) {
		if (in == '\n') {
			y += 1;
			xs = x;
			x = 0;
		} else {
			buf[x++][y] = in;
		}
	}
	ys = y;
	char *pastbufs = malloc(xs*ys*10000);
	copybuf(buf, pastbufs, xs, ys);
	printb(buf, xs, ys);
	moverocks(buf, xs, ys, 0, -1);
	printb(buf, xs, ys);
	printf("Load: %i\n", load(buf, xs, ys));
	char *store = pastbufs;
	int clen;
	int i;
	for(i=1; ; i++) {
		cycle(buf, xs, ys);
		store += xs * ys;
		copybuf(buf, store, xs, ys);
		clen = findbuf(store, pastbufs, xs * ys);
		if (clen > 0) {
			printf("Found at %i\n", clen);
			break;
		}
		printb(buf, xs, ys);
		printf("Load: %i\n", load(buf, xs, ys));
	}
	// After i cycles, found dup at i - clen.
	int remain = 1000000000 - i;
	int need = remain % clen;
	// After remain, we will be need further into the cycle.
	for(int j=0; j<need; j++) {
		cycle(buf, xs, ys);
	}
	printf("Load: %i\n", load(buf, xs, ys));
}

