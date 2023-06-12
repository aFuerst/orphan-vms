set pagination off
set logging overwrite on 
set logging file ./ch-vmm.log
set logging on
set logging redirect on

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

target remote :2345
continue