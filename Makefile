INCLUDE=
LIBPATH=
CFLAGS=-O3 -march=native -mtune=native -g -Wall -Wunreachable-code $(INCLUDE)
# -fprefetch-loop-arrays -floop-parallelize-all -floop-strip-mine -floop-interchange -floop-block -floop-parallelize-all -ftree-loop-if-convert-stores -ftree-loop-if-convert -ftree-loop-distribution
LDFLAGS=-g $(LIBPATH)
CC=gcc

MAIN=pmdemod symdemod decode decode_port
OLD=icesync bitsync framer vdecode vdecode_port
TESTS=hybridtest fanotest vtest224sse vtest224port simtest
MISC=$(TESTS) gensine spindown autocorrelate

all: $(MAIN)

install: all
	install $(MAIN) ~/bin/

check: $(TESTS)
	@for test in $(TESTS); do \
	  echo $${test}; ./$${test}; \
	done

old: $(OLD)

misc: $(MISC)

decode: decode.o viterbi224_sse2.o timeformat.o metrics.o fano.o
	gcc $(LDFLAGS) -o $@ $^  -lm

# portable version of Viterbi for non-x86/SSE2 machines (much slower)
decode_port: decode.o viterbi224_port.o timeformat.o metrics.o fano.o
	gcc $(LDFLAGS) -o $@ $^  -lm

autocorrelate: autocorrelate.o
	gcc $(LDFLAGS) -o $@ $^ -lfftw3 -lm	

qdecode: qdecode.o
	gcc $(LDFLAGS) -o $@ $^ 

framer: framer.o timeformat.o
	gcc $(LDFLAGS) -o $@ $^

vdecode: vdecode.o viterbi224_sse2.o timeformat.o
	gcc $(LDFLAGS) -o $@ $^ 

# portable version of Viterbi for non-x86/SSE2 machines (much slower)
vdecode_port: vdecode.o viterbi224_port.o timeformat.o
	gcc $(LDFLAGS) -o $@ $^ 

symdemod: symdemod.o timeformat.o
	gcc $(LDFLAGS) -o $@ $^ -lm

bitsync: bitsync.o viterbi224_sse2.o timeformat.o
	gcc $(LDFLAGS) -o $@ $^ -lfftw3 -lm

spindown: spindown.o
	gcc $(LDFLAGS) -o $@ $^ -lfftw3 -lm

icesync: icesync.o  viterbi224_sse2.o encode.o fano.o metrics.o
	gcc $(LDFLAGS) -o $@ $^ -lfftw3 -lm

gensine: gensine.o
	gcc $(LDFLAGS) -o $@ $^ -lm

pmdemod: pmdemod.o timeformat.o
	gcc $(LDFLAGS) -o $@ $^ -lfftw3 -lm

hybridtest: hybridtest.o encode.o viterbi224_sse2.o fano.o metrics.o sim.o
	gcc $(LDFLAGS) -o $@ $^ -lm

simtest: simtest.o sim.o
	gcc $(LDFLAGS) -o $@ $^ -lm

vtest224sse: vtest224.o encode.o viterbi224_sse2.o sim.o
	gcc $(LDFLAGS) -o $@ $^ -lm

vtest224port: vtest224.o encode.o viterbi224_port.o sim.o
	gcc $(LDFLAGS) -o $@ $^ -lm

fanotest: fanotest.o encode.o fano.o metrics.o sim.o
	gcc $(LDFLAGS) -o $@ $^ -lm

addnoise: addnoise.o sim.o
	gcc $(LDFLAGS) -o $@ $^ -lm

bitsync.o: bitsync.c code.h viterbi224.h timeformat.h

icesync.o: icesync.c code.h viterbi224.h

vtest224.o: vtest224.c sim.h viterbi224.h

framer.o: framer.c

vdecode.o: vdecode.c code.h viterbi224.h

pmdemod.o: pmdemod.c

symdemod.o: symdemod.c timeformat.h

fano.o: fano.c fano.h

viterbi224_sse2.o: viterbi224_sse2.c viterbi224.h

viterbi224_port.o: viterbi224_port.c viterbi224.h

hybridtest.o: hybridtest.c fano.h viterbi224.h

encode.o: encode.c code.h

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<


clean:
	rm -f *.o $(MAIN) $(OLD) $(MISC)

