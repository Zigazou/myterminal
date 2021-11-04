CC=gcc
CFLAGS=-Wall -Os -std=gnu99 -s -fno-stack-protector -ffunction-sections -fdata-sections -Wl,--gc-sections -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-math-errno -fno-ident -fmerge-all-constants -ffast-math -Wl,-z,norelro -Wl,--hash-style=gnu -Wl,--build-id=none
LDFLAGS=
EXEC=demo-myterminal

ALL: $(EXEC)

%.o: %.c %.h
	$(CC) $(CFLAGS) -o $@ -c $<

error_message.o:
serial.o: error_message.o

demo-myterminal: demo-myterminal.c error_message.o serial.o myt/mytbutton.o myt/mytwidget.o myt/mytcodes.h myt/mytcheckbox.o myt/mytframe.o myt/mytprogress.o
	$(CC) $(CFLAGS) -o $@ $^
	strip $(EXEC)

clean:
	rm -f *.o core

mrproper: clean
	rm -f $(EXEC)
