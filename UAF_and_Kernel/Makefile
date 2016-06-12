#search for gcc
GCC_BIN=`xcrun --sdk iphoneos --find g++`

#search for strip
STRIP_BIN=`xcrun --sdk iphoneos --find strip`

#search for as
AS=`xcrun --sdk iphoneos -f as`

#search for sdk
SDK=`xcrun --sdk iphoneos --show-sdk-path`

#
CODESIGN_ALLOCATE=`xcrun --find codesign_allocate`


CFLAGS = -fvisibility=hidden -fvisibility-inlines-hidden
GCC_BASE = $(GCC_BIN) -Os $(CFLAGS)  -Wimplicit -isysroot $(SDK) -F$(SDK)/System/Library/Frameworks -F$(SDK)/System/Library/PrivateFrameworks

#setup for armv7 iphone 4s
GCC=$(GCC_BASE) -arch armv7


all: hello

hello: hello.cpp
	$(GCC) -D__DARW_OUTPUT__  -o $@ -framework Foundation $^
	CODESIGN_ALLOCATE=$(CODESIGN_ALLOCATE) ldid -Sent.xml $@

.PHONY: all clean

clean:
	rm -f *.o hello
