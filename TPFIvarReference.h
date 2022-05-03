//
//  TPFIvarReference.h
//  TPFControllerAllocTrace
//
//  Created by Pengfei Tian on 2022/5/1.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, TPFType) {
  TPFObjectType,
  TPFBlockType,
  TPFStructType,
  TPFUnknownType,
};

NS_ASSUME_NONNULL_BEGIN

@interface TPFIvarReference : NSObject

@property (nonatomic, copy, readonly, nullable) NSString *name;
@property (nonatomic, readonly) TPFType type;
@property (nonatomic, readonly) ptrdiff_t offset;
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly, nonnull) Ivar ivar;

- (NSUInteger)indexInIvarLayout;

- (nonnull instancetype)initWithIvar:(nonnull Ivar)ivar;

@end

NS_ASSUME_NONNULL_END
