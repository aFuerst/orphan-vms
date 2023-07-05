#define _GNU_SOURCE
#include <sched.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

void cpu_burn(void) {
    int x = 1;
    while(1) {
        x *= 2;
        x &= 0xbadcafe;
    }
}

int main(int argc, char* argv[]) {
    int r, pid, count, core;
    cpu_set_t affinity_mask;
    pid = getpid();
    core=0;

    for(count=0; count < argc; count++) {
        if (strcmp(argv[count], "--core") == 0) {
            core = atoi(argv[count+1]);
            break;
        }
    }
    if (core <= 0) {
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

    cpu_burn();
}