#define _GNU_SOURCE
#include <sched.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

uint iters = 10*1000*1000; // 10 million default

void cpu_burn(void) {
    int i = 0;
    int x = 1;
    for(; i < 1000; ++i) {
        x *= 2;
        x &= 0xbadcafe;
    }
}

int print_help(void) {
    printf("--core [num]");
    printf("--iters [num], default %u", iters);
    return 0;
}

int main(int argc, char* argv[]) {
    int r, pid, count, core;
    double function_time;
    cpu_set_t affinity_mask;
    clock_t start, end;
    pid = getpid();
    core=-1;

    for(count=0; count < argc; count++) {
        if (strcmp(argv[count], "--core") == 0) {
            core = atoi(argv[count+1]);
        } else if (strcmp(argv[count], "--iters") == 0) {
            iters = atoi(argv[count+1]);
        } else if (strcmp(argv[count], "--help") == 0) {
            return print_help();
        } else {
            printf("Unknown arg %s", argv[count]);
            return print_help();
        }
    }
    if (core < 0) {
        perror("Must provide a core to pin to\n");
        return 1;
    }
    CPU_ZERO(&affinity_mask);
    CPU_SET(core, &affinity_mask);

    r = sched_setaffinity(pid, sizeof(affinity_mask), &affinity_mask);
    if (r != 0) {
        printf("failed to set sched_setaffinity: %d\n", r);
        return 1;
    }

    start = clock();
    for (r=0; r < iters; ++r) {
        cpu_burn();
    }

    end = clock();
    function_time = (double)(end - start) / CLOCKS_PER_SEC;
    printf("CPU burn took %f sec\n",function_time);
}