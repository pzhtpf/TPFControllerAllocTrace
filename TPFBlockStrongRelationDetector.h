//
//  TPFBlockStrongRelationDetector.h
//  TPFControllerAllocTrace
//
//  Created by Pengfei Tian on 2022/5/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

struct _block_byref_block;
@interface TPFBlockStrongRelationDetector : NSObject {
    // __block fakery
    void *forwarding;
    int flags;   //refcount;
    int size;
    void (*byref_keep)(struct _block_byref_block *dst, struct _block_byref_block *src);
    void (*byref_dispose)(struct _block_byref_block *);
    void *captured[16];
}

@property (nonatomic, assign, getter=isStrong) BOOL strong;

- (oneway void)trueRelease;

- (void *)forwarding;

@end

NS_ASSUME_NONNULL_END
