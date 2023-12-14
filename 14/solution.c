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

int main(int argv, char **argc) {
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
	printb(buf, xs, ys);
	// Move rocks north
	for(int x=0; x<xs; x++) {
		int ry = 0;
		for (int y=0; y<ys; y++) {
			if (ry <= y)
				ry = y + 1;
			if (buf[x][y] == '.') {
				for (; ry<ys && buf[x][ry] != '#'; ry++) {
					if (buf[x][ry] == 'O') {
						buf[x][ry] = '.';
						buf[x][y] = 'O';
						break;
					}
				}
			}
		}
	}
	printb(buf, xs, ys);
	int load = 0;
	for(int y=0; y<ys; y++) {
		for(int x=0; x<xs; x++) {
			if (buf[x][y] == 'O') {
				load += ys - y;
			}
		}
	}
	printf("Load: %i\n", load);
}

