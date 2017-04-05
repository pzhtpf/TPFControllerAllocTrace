//
//  TestAllocBlock.h
//  TPFControllerAllocTrace
//
//  Created by Roc.Tian on 2017/4/5.
//  Copyright © 2017年 Roc.Tian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TestSubAllocBlock)();

@interface TestAllocBlock : NSObject

@property(nonatomic) TestSubAllocBlock testAllocBlock;

@end
