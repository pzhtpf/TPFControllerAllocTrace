//
//  TPFObjectInStructReference.m
//  TPFControllerAllocTrace
//
//  Created by Pengfei Tian on 2022/5/15.
//

#import "TPFObjectInStructReference.h"
#import "TPFClassStrongLayoutHelpers.h"

@implementation TPFObjectInStructReference
{
  NSUInteger _index;
  NSArray<NSString *> *_namePath;
}

- (instancetype)initWithIndex:(NSUInteger)index
                     namePath:(NSArray<NSString *> *)namePath
{
  if (self = [super init]) {
    _index = index;
    _namePath = namePath;
  }

  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"[in_struct; index: %td]", _index];
}

#pragma mark - TPFObjectReference

- (id)objectReferenceFromObject:(id)object
{
  return TPFExtractObjectByOffset(object, _index);
}

- (NSUInteger)indexInIvarLayout
{
  return _index;
}

- (NSArray<NSString *> *)namePath
{
  return _namePath;
}

@end
