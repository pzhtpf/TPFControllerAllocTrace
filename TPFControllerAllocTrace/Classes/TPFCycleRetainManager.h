//
//  TPFCycleRetainManager.h
//  TPFControllerAllocTrace
//
//  Created by pengfei tian on 2022/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPFCycleRetainManager : NSObject

+(instancetype)shared;
-(void)analyse:(id)object;

@end

NS_ASSUME_NONNULL_END
