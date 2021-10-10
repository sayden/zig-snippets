libfunction:
	gcc -shared -fPIC -o libmylib.so c-libfunction.c
	zig run c-libfunction.zig -lc -lmylib -L. -I.

curl:
	zig run c-libcurl.zig -lcurl -lc $(pkg-config --cflags libcurl)

ray:
	zig run c-ray.zig -lc -lraylib -I${HOME}/software/raylib

clean:
	rm libmylib.so