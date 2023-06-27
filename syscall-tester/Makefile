EXE=systest

systest: systest.c
	gcc -o $(EXE) systest.c
	cp $(EXE) ../rootfs-overlay/home

clean:
	rm -f *.o $(EXE)