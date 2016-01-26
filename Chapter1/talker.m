#import "Talker.h"

@implementation Talker

- (void) say: (NSString*) phrase {
  NSLog(@"%@\n", phrase);
}

@end
