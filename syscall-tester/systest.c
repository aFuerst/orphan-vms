#include <sys/syscall.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    int r, pid;
    pid = getpid();
    r = syscall(451, pid, 1); // orphan
    if (r != 0) {
        printf("unexpected orphan return code: %d\n", r);
        exit(1);
    }
    r = syscall(452, pid, 1); // adopt
    if (r != 0) {
        printf("unexpected adopt return code: %d\n", r);
        exit(1);
    }
}