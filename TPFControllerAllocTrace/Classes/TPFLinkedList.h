//
//  TPFLinkedList.h
//  TPFControllerAllocTrace
//
//  Created by pengfei tian on 2022/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPFLinkedList : NSObject

@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) TPFLinkedList *next;
@property (strong, nonatomic) TPFLinkedList *childrens;

@end

NS_ASSUME_NONNULL_END
