EXE=systest

systest: systest.c pintest.c
	gcc -o $(EXE) -static systest.c
	cp $(EXE) ../rootfs-overlay/home
	gcc -o pintest -static pintest.c
	cp pintest ../rootfs-overlay/home

clean:
	rm -f *.o $(EXE) pintest