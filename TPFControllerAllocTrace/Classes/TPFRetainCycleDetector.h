//
//  TPFRetainCycleDetector.h
//  TPFControllerAllocTrace
//
//  Created by Pengfei Tian on 2022/5/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPFRetainCycleDetector : NSObject

- (instancetype)initWithObject:(id)object;

@end

NS_ASSUME_NONNULL_END
