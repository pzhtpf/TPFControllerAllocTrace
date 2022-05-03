//
//  TPFRetainCycleDetector.m
//  TPFControllerAllocTrace
//
//  Created by Pengfei Tian on 2022/5/1.
//

#import "TPFRetainCycleDetector.h"
#import <objc/runtime.h>
#import "TPFLinkedList.h"
#import "TPFClassStrongLayout.h"

@interface TPFRetainCycleDetector ()

@property (strong, nonatomic) NSMutableDictionary *layoutCache;

@end

@implementation TPFRetainCycleDetector

- (instancetype)initWithObject:(id)object {
    self = [super init];
    if (self) {
        self.layoutCache = [[NSMutableDictionary alloc] init];
        [self analyse:object];
    }
    return self;
}

#pragma public API
- (void)analyse:(id)object {
    NSMutableDictionary *vertexs = [[NSMutableDictionary alloc] init];
    TPFLinkedList *head = [self findInstanceObject:object vertexs:vertexs];
    head.className = NSStringFromClass([object class]);
    head.propertyName = @"headViewController";
    [self graphIfExistCycle:head vertexs:vertexs];
}

- (TPFLinkedList *)findInstanceObject:(id)object vertexs:(NSMutableDictionary *)vertexs {
    TPFLinkedList *node = [[TPFLinkedList alloc] init];
//    node.className = NSStringFromClass([object class]);
    node.address = [NSString stringWithFormat:@"%p", object];
    [vertexs setObject:node forKey:node.address];

    TPFLinkedList *head;

    TPFClassStrongLayout *strongLayout = [[TPFClassStrongLayout alloc] init];
    NSArray<TPFIvarReference *> *strongReferences = [strongLayout getObjectStrongReferences:object layoutCache:self.layoutCache];

    NSInteger count = strongReferences.count;

    NSMutableDictionary *keyPathClassNames = [NSMutableDictionary new];

    NSInteger i;
    for (i = 0; i < count; i++) {
        TPFIvarReference *ivarReference = strongReferences[i];
        NSString *propertyName = ivarReference.name;

        id propertyObject = [ivarReference objectReferenceFromObject:object];
        if (propertyObject != nil) {
            NSString *className = NSStringFromClass([propertyObject class]);
            [keyPathClassNames setValue:className forKey:propertyName];
            NSString *addressKey = [NSString stringWithFormat:@"%p", propertyObject];
            TPFLinkedList *childNode;
            if ([vertexs objectForKey:addressKey] == nil) {
                childNode = [self findInstanceObject:propertyObject vertexs:vertexs];
            } else {
                childNode = [[TPFLinkedList alloc] init];
                childNode.address = addressKey;
            }
            childNode.propertyName = propertyName;
            childNode.className = className;
            if (!head) {
                head = childNode;
                node.childrens = head;
            } else {
                head.next = childNode;
                head = head.next;
            }
        }
    }

    return node;
}

- (void)graphIfExistCycle:(TPFLinkedList *)head vertexs:(NSMutableDictionary *)vertexs {
    NSMutableArray *cyclePath = [[NSMutableArray alloc] init];
    [self dfs:head path:[NSMutableArray new] visited:[NSMutableDictionary new] cyclePath:cyclePath];
    NSLog(@"cyclePathCount:%ld", cyclePath.count);
}

- (void)dfs:(TPFLinkedList *)head path:(NSMutableArray *)path visited:(NSMutableDictionary *)visited cyclePath:(NSMutableArray *)cyclePath {
    if ([visited objectForKey:head.address]) { /* 说明存在环 */
        [path addObject:head];
        [path addObject:[visited objectForKey:head.address]];
        NSMutableArray *serializeArray = [self serializeCyclePath:path];
        [cyclePath addObject:[serializeArray description]];
        [path removeLastObject];
        [path removeLastObject];
        return;
    }

    [path addObject:head];
    [visited setObject:head forKey:head.address];

    TPFLinkedList *childHead = head.childrens;
    while (childHead) {
        [self dfs:childHead path:path visited:visited cyclePath:cyclePath];
        childHead = childHead.next;
    }

    [path removeLastObject];
    [visited removeObjectForKey:head.address];
}

- (NSMutableArray *)serializeCyclePath:(NSMutableArray *)cyclePath {
    NSMutableArray *serializeArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < cyclePath.count; i++) {
        TPFLinkedList *node = cyclePath[i];
        NSString *string = [NSString stringWithFormat:@"ClassName=%@;PropertyName=%@;Address=%@", node.className, node.propertyName, node.address];
        [serializeArray addObject:string];
    }
    return serializeArray;
}

@end
