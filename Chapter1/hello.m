#import "Talker.h"
#include <dlfcn.h>
#include <mach-o/dyld_images.h>
#include <objc/runtime.h>


int main(void) {
    
    Talker *talker = [[Talker alloc] init];
    [talker say: @"Hello, Ice and Fire!"];
    [talker say: @"Hello, Ice and Fire!"];
    [talker release];

}

