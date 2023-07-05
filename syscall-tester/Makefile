EXE=systest

systest: systest.c pintest.c
	gcc -o $(EXE) systest.c
	cp $(EXE) ../rootfs-overlay/home
	gcc -o pintest pintest.c
	cp pintest ../rootfs-overlay/home

clean:
	rm -f *.o $(EXE) pintest