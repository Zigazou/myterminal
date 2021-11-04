CC=gcc
CFLAGS=-Wall -Os -std=gnu99 -s -fno-stack-protector -ffunction-sections -fdata-sections -Wl,--gc-sections -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-math-errno -fno-ident -fmerge-all-constants -ffast-math -Wl,-z,norelro -Wl,--hash-style=gnu -Wl,--build-id=none
LDFLAGS=

%.o: %.c %.h
	$(CC) $(CFLAGS) -o $@ -c $<

mytwidget.o:
mytframe.o: mytcodes.h mytwidget.o
mytbutton.o: mytcodes.h mytwidget.o
mytcheckbox.o: mytcodes.h mytwidget.o
mytprogress.o: mytcodes.h mytwidget.o

clean:
	rm -f *.o
