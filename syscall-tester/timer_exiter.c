#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <string.h>

#define CLOCKID CLOCK_REALTIME
#define SIG SIGALRM

#define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
                    } while (0)

static void print_siginfo(siginfo_t *si) {
    int      or;
    timer_t  *tidp;

    tidp = si->si_value.sival_ptr;

    printf("    sival_ptr = %p; ", si->si_value.sival_ptr);
    printf("    *sival_ptr = %#jx\n", (uintmax_t) *tidp);

    or = timer_getoverrun(*tidp);
    if (or == -1)
        errExit("timer_getoverrun");
    else
        printf("    overrun count = %d\n", or);
}

static void handler(int sig, siginfo_t *si, void *uc) {
    static unsigned long long cnt = 0;
    /* Note: calling printf() from a signal handler is not safe
        (and should not be done in production programs), since
        printf() is not async-signal-safe; see signal-safety(7).
        Nevertheless, we use printf() here as a simple way of
        showing that the handler was called. */
    // 
    // exit(0);
    if (++cnt % 10000 == 0)  {
        printf("here %llu\n", ++cnt);
    }

    // printf("Caught signal %d\n", sig);
    // print_siginfo(si);
    // signal(sig, SIG_IGN);
}

int print_help(void) {
    printf("--ns-freq [num] : time between timer ticks\n");
}

int main(int argc, char *argv[]) {
    int count;
    timer_t            timerid;
    sigset_t           mask;
    long long          freq_nanosecs = 50000;
    struct sigevent    sev;
    struct sigaction   sa;
    struct itimerspec  its;

    for(count=0; count < argc; count++) {
        if (strcmp(argv[count], "--ns-freq") == 0) {
            freq_nanosecs = atoll(argv[count+1]);
            ++count;
        } else if (strcmp(argv[count], "--help") == 0) {
            return print_help();
        }
    }
    /* Establish handler for timer signal. */

    printf("Establishing handler for signal %d\n", SIG);
    sa.sa_flags = SA_SIGINFO;
    sa.sa_sigaction = handler;
    sigemptyset(&sa.sa_mask);
    if (sigaction(SIG, &sa, NULL) == -1)
        errExit("sigaction");

    /* Block timer signal temporarily. */

    // printf("Blocking signal %d\n", SIG);
    // sigemptyset(&mask);
    // sigaddset(&mask, SIG);
    // if (sigprocmask(SIG_SETMASK, &mask, NULL) == -1)
    //     errExit("sigprocmask");

    /* Create the timer. */

    sev.sigev_notify = SIGEV_SIGNAL;
    sev.sigev_signo = SIG;
    sev.sigev_value.sival_ptr = &timerid;
    if (timer_create(CLOCKID, &sev, &timerid) == -1)
        errExit("timer_create");

    printf("timer ID is %#jx\n", (uintmax_t) timerid);

    /* Start the timer. */

    // freq_nanosecs = atoll(argv[2]);
    its.it_value.tv_sec = 0;
    its.it_value.tv_nsec = freq_nanosecs;
    its.it_interval.tv_sec = its.it_value.tv_sec;
    its.it_interval.tv_nsec = its.it_value.tv_nsec;

    if (timer_settime(timerid, 0, &its, NULL) == -1)
        errExit("timer_settime");

    /* Sleep for a while; meanwhile, the timer may expire
        multiple times. */

    // printf("Sleeping for %d seconds\n", atoi(argv[1]));
    // sleep(atoi(argv[1]));

    /* Unlock the timer signal, so that timer notification
        can be delivered. */

    // printf("Unblocking signal %d\n", SIG);
    // if (sigprocmask(SIG_UNBLOCK, &mask, NULL) == -1)
    //     errExit("sigprocmask");

    for (;;) {
        pause();
        // sleep(10);
        // perror("itering\n");
    }


    exit(EXIT_SUCCESS);
}