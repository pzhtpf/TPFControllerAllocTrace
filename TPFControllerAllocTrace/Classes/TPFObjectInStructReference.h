//
//  TPFObjectInStructReference.h
//  TPFControllerAllocTrace
//
//  Created by Pengfei Tian on 2022/5/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPFObjectInStructReference : NSObject

/**
 Struct object is an Objective-C object that is created inside
 a struct. In Objective-C++ that object will be retained
 by an object owning the struct, therefore will be listed in
 ivar layout for the class.
 */

- (nonnull instancetype)initWithIndex:(NSUInteger)index
                             namePath:(nullable NSArray<NSString *> *)namePath;

@end

NS_ASSUME_NONNULL_END
