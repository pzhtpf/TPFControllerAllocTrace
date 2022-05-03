//
//  TPFClassStrongLayout.h
//  TPFControllerAllocTrace
//
//  Created by Pengfei Tian on 2022/5/3.
//

#import <Foundation/Foundation.h>
#import "TPFIvarReference.h"

NS_ASSUME_NONNULL_BEGIN

@interface TPFClassStrongLayout : NSObject

- (NSArray *)getObjectStrongReferences:(id)obj layoutCache:(NSMutableDictionary *)layoutCache;

@end

NS_ASSUME_NONNULL_END
