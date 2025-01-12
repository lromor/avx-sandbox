CC?=gcc
CFLAGS?=-g -O1
#LDFLAGS?=-nostdlib
#LDFLAGS?=-nostdlib

main: main.o hello-world.o
	gcc $(LDFLAGS) -o $@  $^

%.o: %.S
	$(CC) $(CFLAGS) -c $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

clean:
	rm -f main *.o

.PHONY: clean
