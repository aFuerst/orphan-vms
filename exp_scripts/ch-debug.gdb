handle all noprint pass
handle SIGHUP stop pass
handle SIGINT stop nopass
handle SIGQUIT stop pass
handle SIGILL stop pass
handle SIGTRAP stop nopass
handle SIGABRT stop pass
handle SIGEMT stop pass
handle SIGFPE stop pass
handle SIGKILL stop pass
handle SIGBUS stop pass
handle SIGSEGV stop pass
handle SIGPIPE stop pass
handle SIGTERM stop pass

set pagination off
set non-stop on
target remote :2345
break spawn_virtio_thread
# break listen_for_sigwinch_on_tty
continue