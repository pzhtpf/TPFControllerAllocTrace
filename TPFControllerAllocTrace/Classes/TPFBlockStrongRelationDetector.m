//
//  TPFBlockStrongRelationDetector.m
//  TPFControllerAllocTrace
//
//  Created by Pengfei Tian on 2022/5/3.
//

#if __has_feature(objc_arc)
#error This file must be compiled with MRR. Use -fno-objc-arc flag.
#endif

#import "TPFBlockStrongRelationDetector.h"
#import <objc/runtime.h>

static void byref_keep_nop(struct _block_byref_block *dst, struct _block_byref_block *src) {}
static void byref_dispose_nop(struct _block_byref_block *param) {}

@implementation TPFBlockStrongRelationDetector

- (oneway void)release {
  _strong = YES;
}

- (id)retain {
  return self;
}

+ (id)alloc {
  TPFBlockStrongRelationDetector *obj = [super alloc];

  // Setting up block fakery
  obj->forwarding = obj;
  obj->byref_keep = byref_keep_nop;
  obj->byref_dispose = byref_dispose_nop;

  return obj;
}

- (oneway void)trueRelease {
  [super release];
}

- (void *)forwarding {
  return self->forwarding;
}

@end
