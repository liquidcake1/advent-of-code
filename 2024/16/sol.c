#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <limits.h>
#include <malloc.h>
#include <stdlib.h>

#define LOC(row, col) ((width + 1) * row + col)

typedef struct grid_loc_S {
    char dir;
    int row;
    int col;
} grid_loc;

typedef struct queue_item_S {
    int score;
    grid_loc loc;
} queue_item;

typedef struct heap_S {
    queue_item* items;
    int size;
    int capacity;
} heap;

heap *create_heap(int capacity) {
    heap *h = (heap*)malloc(sizeof(heap));
    h->items = (queue_item*)malloc(sizeof(queue_item) * capacity);
    h->size = 0;
    h->capacity = capacity;
}

void swap_item(queue_item *left, queue_item *right) {
    queue_item tmp = *right;
    *right = *left;
    *left = tmp;
}

void fix_down(heap *h, int idx) {
    int left_idx = idx * 2 + 1;
    int right_idx = left_idx + 1;
    int smallest;
    if (right_idx < h->size) {
        if (h->items[right_idx].score > h->items[left_idx].score) 
            smallest = left_idx;
        else
            smallest = right_idx;
    } else if (left_idx < h->size)
        smallest = left_idx;
    else
        return;
    if (h->items[smallest].score < h->items[idx].score) {
        swap_item(&h->items[smallest], &h->items[idx]);
        fix_down(h, smallest);
    }
}

queue_item heap_pop(heap *h) {
    queue_item our_item = h->items[0];
    h->size--;
    if (h->size > 0) {
        h->items[0] = h->items[h->size];
        fix_down(h, 0);
    }
    return our_item;
}

void fix_up(heap *h, int idx) {
    if (idx == 0)
        return;
    int parent_idx = (idx - 1) / 2;
    if (h->items[parent_idx].score > h->items[idx].score) {
        swap_item(&h->items[parent_idx], &h->items[idx]);
        fix_up(h, parent_idx);
    }
}

void heap_push(heap *h, queue_item q) {
    int idx = h->size;
    h->size += 1;
    if (h->size > h->capacity) {
        fprintf(stderr, "Heap overflow");
        exit(1);
    }
    h->items[idx] = q;
    fix_up(h, idx);
}



int main() {
    char buf[1024*1204];
    int s = read(0, buf, sizeof(buf));
    write(1, buf, s);
    int width = strchr(buf, '\n') - buf;
    printf("%i\n", width);
    int height = s / (width + 1);
    printf("%f\n", (1.0 * s / (width + 1)));
    printf("%c\n", buf[LOC(13,1)]);
    int best[4][height][width];
    int is_best[height][width];
    for(int dir=0; dir < 4; dir++) {
        for(int row=0; row < height; row++) {
            for(int col=0; col < width; col++) {
                best[dir][row][col] = INT_MAX;
                is_best[row][col] = 0;
            }
        }
    }
    int start_row = height - 2;
    int start_col = 1;
    int start_dir = 0; // east
    heap *heap = create_heap(width * width);
    heap_push(heap, (queue_item){0, {start_dir, start_row, start_col}});
    int dvec[4][2] = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}};
    while (heap->size >= 1) {
        queue_item startq = heap_pop(heap);
        grid_loc start = startq.loc;
        fprintf(stderr, "%i %i %i %c %i\n", (int)start.dir, start.row, start.col, buf[LOC(start.row, start.col)], startq.score);
        int current_score = best[start.dir][start.row][start.col];
        if (current_score <= startq.score) continue;
        if (buf[LOC(start.row, start.col)] == '#') continue;
        best[start.dir][start.row][start.col] = startq.score;
        // turn left
        heap_push(heap, (queue_item){startq.score + 1000, {(start.dir + 3) % 4, start.row, start.col}});
        // turn right
        heap_push(heap, (queue_item){startq.score + 1000, {(start.dir + 1) % 4, start.row, start.col}});
        // go forward
        heap_push(heap, (queue_item){startq.score + 1, {start.dir, start.row + dvec[start.dir][0], start.col + dvec[start.dir][1]}});
    }
    int best_score = INT_MAX;
    queue_item queue[width];
    for(int i=0; i<4; i++)
        if (best[i][1][width - 2] < best_score) {
            best_score = best[i][1][width - 2];
            queue[0] = (queue_item){best_score, {i, 1, width - 2}};
        }
    int queue_pos = 0;
    int bests = 0;
    while(queue_pos >= 0) {
        grid_loc start = queue[queue_pos].loc;
        if (!is_best[start.row][start.col]) {
            is_best[start.row][start.col] = 1;
            bests += 1;
        }
        queue_item potentials[3] = {
            // unturn left
            (queue_item){queue[queue_pos].score - 1000, {(start.dir + 1) % 4, start.row, start.col}},
            // unturn right
            (queue_item){queue[queue_pos].score - 1000, {(start.dir + 3) % 4, start.row, start.col}},
            // ungo forward
            (queue_item){queue[queue_pos].score - 1, {start.dir, start.row - dvec[start.dir][0], start.col - dvec[start.dir][1]}}
        };
        queue_pos--;
        for(int i=0; i<3; i++) {
            queue_item potential = potentials[i];
            if (potential.score == best[potential.loc.dir][potential.loc.row][potential.loc.col]) {
                queue[++queue_pos] = potential;
            }
        }
    }
    for(int row=0; row<height; row++) {
        for(int col=0; col<width; col++) {
            int min = INT_MAX;
            for (int dir=0; dir<4; dir++) {
                if (best[dir][row][col] < min) min = best[dir][row][col];
            }
            if (min == INT_MAX)
                min = -1;
            printf("%5i ", min);
        }
        putc('\n', stdout);
    }
    for(int row=0; row<height; row++) {
        for(int col=0; col<width; col++) {
            if (is_best[row][col]) {
                putc('O', stdout);
            } else {
                putc(buf[LOC(row, col)], stdout);
            }
        }
        putc('\n', stdout);
    }

    
    printf("Final score = %i\n", best_score);
    printf("Cells on best path = %i\n", bests);

}
