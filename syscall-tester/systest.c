#include <sys/syscall.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    int r, pid;
    pid = getpid();
    r = syscall(451, pid, 1); // orphan
    if (r != 0) {
        fprintf(stderr, "%s", "unexpected orphan return code: %d\n", r);
        exit(1);
    }
    r = syscall(452, pid, 1); // adopt
    if (r != 0) {
        fprintf(stderr, "%s", "unexpected adopt return code: %d\n", r);
        exit(1);
    }
    printf("syscall test OK\n");
    return 0;
}