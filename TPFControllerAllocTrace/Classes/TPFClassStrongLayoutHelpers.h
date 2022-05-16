//
//  TPFClassStrongLayoutHelpers.h
//  TPFControllerAllocTrace
//
//  Created by Pengfei Tian on 2022/5/15.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 Returns object on given index for obj in its ivar layout.
 It will try to map the object to an Objective-C object, so if the index
 is invalid it will crash with BAD_ACCESS.

 It cannot be called under ARC.
 */
id TPFExtractObjectByOffset(id obj, NSUInteger index);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TPFClassStrongLayoutHelpers : NSObject

@end

NS_ASSUME_NONNULL_END
