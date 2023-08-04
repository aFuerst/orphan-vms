#include <stdio.h>
#include <time.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

int print_help(void) {
    printf("--iters [num] : number of cpuid instructions to execute\n");
}

int main(int argc, char *argv[]) {
    int i, eax, ebx, ecx, edx;
    int iters = 1000000;
    double function_time;
    clock_t start, end;

    for(i=0; i < argc; i++) {
        if (strcmp(argv[i], "--iters") == 0) {
            iters = atoi(argv[i+1]);
            ++i;
        } else if (strcmp(argv[i], "--help") == 0) {
            return print_help();
        }
    }

    start = clock();

    for (i=0; i < iters; i++)
        asm volatile("cpuid"
        : "=a" (eax),
        "=b" (ebx),
        "=c" (ecx),
        "=d" (edx)
        : "0" (eax), "2" (ecx)
        : "memory");

    end = clock();
    function_time = (double)(end - start) / CLOCKS_PER_SEC;
    printf("cpuid took %f sec\n",function_time);
}