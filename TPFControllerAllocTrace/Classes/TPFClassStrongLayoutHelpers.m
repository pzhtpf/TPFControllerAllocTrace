//
//  TPFClassStrongLayoutHelpers.m
//  TPFControllerAllocTrace
//
//  Created by Pengfei Tian on 2022/5/15.
//

#import "TPFClassStrongLayoutHelpers.h"

#if __has_feature(objc_arc)
#error This file must be compiled with MRR. Use -fno-objc-arc flag.
#endif

#import "TPFClassStrongLayoutHelpers.h"

id TPFExtractObjectByOffset(id obj, NSUInteger index) {
  id *idx = (id *)((uintptr_t)obj + (index * sizeof(void *)));

  return *idx;
}

@implementation TPFClassStrongLayoutHelpers

@end
