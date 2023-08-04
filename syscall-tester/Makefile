EXE=systest

systest: systest.c pintest.c
	gcc -o $(EXE) -static systest.c
	cp $(EXE) ../rootfs-overlay/home

	gcc -o pintest -static pintest.c
	cp pintest ../rootfs-overlay/home

	gcc -o timer_exiter -static timer_exiter.c
	cp timer_exiter ../rootfs-overlay/home

	gcc -o cpuid -static cpuid.c
	cp cpuid ../rootfs-overlay/home

clean:
	rm -f *.o $(EXE) pintest