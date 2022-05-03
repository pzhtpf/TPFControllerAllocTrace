//
//  TPFBlockStrongLayout.h
//  Aspects
//
//  Created by Pengfei Tian on 2022/5/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPFBlockStrongLayout : NSObject

/**
 Returns an array of id<FBObjectReference> objects that will have only those references
 that are retained by block.
 */
+ (NSArray *_Nullable)TPFGetBlockStrongReferences:(void *_Nonnull)block;
+ (BOOL)TPFObjectIsBlock:(void *_Nullable)object;

@end

NS_ASSUME_NONNULL_END
