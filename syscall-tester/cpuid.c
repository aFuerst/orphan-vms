#include <stdio.h>
#include <time.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

int print_help(void) {
    printf("--iters [num] : number of cpuid instructions to execute\n");
    printf("--minmax : use cpuid instruction to get min/max EAX information usable by from CPUID instruction\n");
    printf("--testall : use cpuid instruction to get min/max EAX information usable by from CPUID instruction\n");
}

void get_minmax(int *min, int *max) {
    int eax, ebx, ecx, edx;
    eax = 0;
    asm volatile("cpuid"
        : "=a" (eax),
        "=b" (ebx),
        "=c" (ecx),
        "=d" (edx)
        : "0" (eax), "2" (ecx)
        : "memory");
    *min = eax;
    eax = 0x80000000;
    asm volatile("cpuid"
        : "=a" (eax),
        "=b" (ebx),
        "=c" (ecx),
        "=d" (edx)
        : "0" (eax), "2" (ecx)
        : "memory");
    *max = eax;
}

int minmax() {
    int min, max;
    get_minmax(&min, &max);

    printf("Basic processor information eax: %X <= %X\n", 0, min);

    printf("Extended processor information eax: %X <= %X\n", 0x80000000, max);
    return 0;
}

int testall() {
    int min, max, i;
    get_minmax(&min, &max);
    int eax, ebx, ecx, edx;
    for (i=0; i <= min; ++i) {
        ebx = ecx = edx = 0;
        eax = i;
        asm volatile("cpuid"
            : "=a" (eax),
            "=b" (ebx),
            "=c" (ecx),
            "=d" (edx)
            : "0" (eax), "2" (ecx)
            : "memory");
        printf("%X => %X %X %X %X\n", i, eax, ebx, ecx, edx);
    }
    for (i=0x80000000; i <= max; ++i) {
        ebx = ecx = edx = 0;
        eax = i;
        asm volatile("cpuid"
            : "=a" (eax),
            "=b" (ebx),
            "=c" (ecx),
            "=d" (edx)
            : "0" (eax), "2" (ecx)
            : "memory");
        printf("%X => %X %X %X %X\n", i, eax, ebx, ecx, edx);
    }
    return 0;
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
        } else if (strcmp(argv[i], "--minmax") == 0) {
            return minmax();
        } else if (strcmp(argv[i], "--testall") == 0) {
            return testall();
        } else if (strcmp(argv[i], "--help") == 0) {
            return print_help();
        }
    }

    start = clock();

    for (i=0; i < iters; i++) 
    {
        eax = ebx = ecx = edx = 0;
        asm volatile("cpuid"
        : "=a" (eax),
        "=b" (ebx),
        "=c" (ecx),
        "=d" (edx)
        : "0" (eax), "2" (ecx)
        : "memory");

    }
    end = clock();
    function_time = (double)(end - start) / CLOCKS_PER_SEC;
    printf("cpuid took %f sec\n",function_time);
}