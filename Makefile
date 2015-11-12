CC = gcc
CXX = g++

CFLAGS = -W -Wall -Wextra -ansi -pedantic -lm
CXXFLAGS = -W -Wall -Wextra -ansi -pedantic

ZDEFOPT = -Ofast
ZARMOPT = -O2
ZADDOPT = -g0 -s -flto -fuse-linker-plugin -ffat-lto-objects -flto-compression-level=0 -finline-functions -funswitch-loops -fpredictive-commoning -ftree-loop-distribute-patterns -ftree-slp-vectorize -ffast-math -fomit-frame-pointer -ftracer -ftree-loop-ivcanon -ftree-loop-distribution -fselective-scheduling2 -fsel-sched-pipelining -fira-region=all -fira-hoist-pressure -free -fno-crossjumping -fno-cx-limited-range -fno-defer-pop -fno-function-cse -fno-rerun-cse-after-loop -fno-sched-interblock -fno-sched-last-insn-heuristic -fno-sched-spec -fno-sel-sched-pipelining-outer-loops -fno-tree-fre -fno-tree-loop-im -fno-zero-initialized-in-bss
# -flto-partition=max - provides ~1% speed up on linux but doesn't work with mingw32 
CAVXFLAGS = -mavx -mtune=corei7-avx -march=corei7-avx
CNEONFLAGS = -march=armv7-a -mcpu=cortex-a9 -mfpu=neon -mfloat-abi=hard -mthumb-interwork -mword-relocations -mno-unaligned-access -mneon-for-64bits

ZOPFLILIB_SRC = src/zopfli/blocksplitter.c src/zopfli/cache.c\
                src/zopfli/inthandler.c src/zopfli/deflate.c\
                src/zopfli/crc32.c src/zopfli/gzip_container.c\
                src/zopfli/zip_container.c src/zopfli/hash.c\
                src/zopfli/katajainen.c src/zopfli/lz77.c\
                src/zopfli/squeeze.c src/zopfli/tree.c\
                src/zopfli/util.c src/zopfli/adler.c\
                src/zopfli/zlib_container.c src/zopfli/zopfli_lib.c
ZOPFLILIB_OBJ := $(patsubst src/zopfli/%.c,%.o,$(ZOPFLILIB_SRC))
ZOPFLIBIN_SRC := src/zopfli/zopfli_bin.c
LODEPNG_SRC := src/zopflipng/lodepng/lodepng.cpp src/zopflipng/lodepng/lodepng_util.cpp
ZOPFLIPNGLIB_SRC := src/zopflipng/zopflipng_lib.cc
ZOPFLIPNGBIN_SRC := src/zopflipng/zopflipng_bin.cc

.PHONY: zopfli zopflipng

# Zopfli binary
zopfli:
	$(CC) -static $(ZOPFLILIB_SRC) $(ZOPFLIBIN_SRC) $(CFLAGS) $(ZDEFOPT) $(ZADDOPT) -o zopfli
	
zopfliavx:
	$(CC) -static $(ZOPFLILIB_SRC) $(ZOPFLIBIN_SRC) $(CFLAGS) $(ZDEFOPT) $(CAVXFLAGS) $(ZADDOPT) -o zopfli

zopflineon:
	$(CC) -static $(ZOPFLILIB_SRC) $(ZOPFLIBIN_SRC) $(CFLAGS) $(ZARMOPT) $(CNEONFLAGS) $(ZADDOPT) -o zopfli

defdbparser:
	$(CC) -static $(DEFDBPARSER_SRC) $(ZARMOPT) -o defdbparser

testlib:
	$(CC) src/libtest/libtest.c -ldl -lpsapi $(CFLAGS) $(ZDEFOPT) $(ZADDOPT) -o zopflitest

# Zopfli shared library
libzopfli:
	$(CC) $(ZOPFLILIB_SRC) $(CFLAGS) $(ZDEFOPT) $(ZADDOPT) -c
	$(CC) $(ZOPFLILIB_OBJ) $(CFLAGS) $(ZDEFOPT) $(ZADDOPT) -shared -Wl,-soname,libzopfli.so.1 -o libzopfli.so.1.0.1

libzopfliavx:
	$(CC) $(ZOPFLILIB_SRC) $(CFLAGS) $(ZDEFOPT) $(CAVXFLAGS) $(ZADDOPT)  -c
	$(CC) $(ZOPFLILIB_OBJ) $(CFLAGS) $(ZDEFOPT) $(CAVXFLAGS) $(ZADDOPT) -shared -Wl,-soname,libzopfli.so.1 -o libzopfli.so.1.0.1

libzopflineon:
	$(CC) $(ZOPFLILIB_SRC) $(CFLAGS) $(ZARMOPT) $(CNEONFLAGS) $(ZADDOPT)  -c
	$(CC) $(ZOPFLILIB_OBJ) $(CFLAGS) $(ZARMOPT) $(CNEONFLAGS) $(ZADDOPT) -shared -Wl,-soname,libzopfli.so.1 -o libzopfli.so.1.0.1

# ZopfliPNG binary
zopflipng:
	$(CC) $(ZOPFLILIB_SRC) $(CFLAGS) $(ZDEFOPT) $(ZADDOPT) -c
	$(CXX) -static -static-libgcc $(ZOPFLILIB_OBJ) $(LODEPNG_SRC) $(ZOPFLIPNGLIB_SRC) $(ZOPFLIPNGBIN_SRC) $(CFLAGS) $(ZDEFOPT) $(ZADDOPT) -o zopflipng
	
zopflipngavx:
	$(CC) $(ZOPFLILIB_SRC) $(CFLAGS) $(ZDEFOPT) $(CAVXFLAGS) $(ZADDOPT) -c
	$(CXX) -static -static-libgcc $(ZOPFLILIB_OBJ) $(LODEPNG_SRC) $(ZOPFLIPNGLIB_SRC) $(ZOPFLIPNGBIN_SRC) $(CFLAGS) $(ZDEFOPT) $(CAVXFLAGS) $(ZADDOPT) -o zopflipng

zopflipngneon:
	$(CC) $(ZOPFLILIB_SRC) $(CFLAGS) $(ZARMOPT) $(CNEONFLAGS) $(ZADDOPT) -c
	$(CXX) -static -static-libgcc $(ZOPFLILIB_OBJ) $(LODEPNG_SRC) $(ZOPFLIPNGLIB_SRC) $(ZOPFLIPNGBIN_SRC) $(CFLAGS) $(ZARMOPT) $(CNEONFLAGS) $(ZADDOPT) -o zopflipng

# ZopfliPNG shared library
libzopflipng:
	$(CC) $(ZOPFLILIB_SRC) $(CFLAGS) $(ZDEFOPT) $(ZADDOPT) -fPIC -c
	$(CXX) $(ZOPFLILIB_OBJ) $(LODEPNG_SRC) $(ZOPFLIPNGLIB_SRC) $(CFLAGS) $(ZDEFOPT) $(ZADDOPT) -fPIC --shared -Wl,-soname,libzopflipng.so.1 -o libzopflipng.so.1.0.0

# Remove all libraries and binaries
clean:
	rm -f zopflipng zopfli $(ZOPFLILIB_OBJ) libzopfli*
