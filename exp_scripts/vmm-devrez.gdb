set pagination off
set logging overwrite on 
set logging file ./ch-vmm.log
set logging on
set logging redirect on

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

#break SerialManager::start_thread::{{closure}}
#break SerialManager::start_thread
# break virtio_devices::balloon::Balloon::new
# break virtio_devices::balloon::BalloonEpollHandler::run
# break virtio_devices::balloon::BalloonEpollHandler::signal::{{closure}}

# break devices::ioapic::{impl#3}::service_irq
# commands 1-1
# where
# continue
# end

target remote /tmp/vmm-gdb.sock
continue