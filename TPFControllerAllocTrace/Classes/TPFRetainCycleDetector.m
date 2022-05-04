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
#import "TPFBlockStrongLayout.h"

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
    TPFLinkedList *head = [self findReference:object vertexs:vertexs];
    head.className = NSStringFromClass([object class]);
    head.propertyName = @"headViewController";
    [self graphIfExistCycle:head vertexs:vertexs];
}

- (TPFLinkedList *)findReference:(id)object vertexs:(NSMutableDictionary *)vertexs {
    if ([TPFBlockStrongLayout TPFObjectIsBlock:(__bridge void *_Nullable)(object)]) {
        return [self findBlockReference:(__bridge void *_Nullable)(object) vertexs:vertexs];
    } else {
        return [self findInstanceObject:object vertexs:vertexs];
    }
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
            NSString *className = ivarReference.className.length == 0 ? NSStringFromClass([propertyObject class]) : ivarReference.className;
            [keyPathClassNames setValue:className forKey:propertyName];
            NSString *addressKey = [NSString stringWithFormat:@"%p", propertyObject];
            TPFLinkedList *childNode;
            if ([vertexs objectForKey:addressKey] == nil) {
                childNode = [self findReference:propertyObject vertexs:vertexs];
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

- (TPFLinkedList *)findBlockReference:(void *_Nonnull)block vertexs:(NSMutableDictionary *)vertexs {
    TPFLinkedList *node = [[TPFLinkedList alloc] init];
    node.address = [NSString stringWithFormat:@"%p", block];
    [vertexs setObject:node forKey:node.address];

    TPFLinkedList *head;

    NSArray *blockReferences = [TPFBlockStrongLayout TPFGetBlockStrongReferences:block];
    NSInteger count = blockReferences.count;
    NSInteger i;
    for (i = 0; i < count; i++) {
        id object = blockReferences[i];
        NSString *className = NSStringFromClass([object class]);
        NSString *addressKey = [NSString stringWithFormat:@"%p", object];
        TPFLinkedList *childNode;
        if ([vertexs objectForKey:addressKey] == nil) {
            childNode = [self findReference:object vertexs:vertexs];
        } else {
            childNode = [[TPFLinkedList alloc] init];
            childNode.address = addressKey;
        }
        childNode.propertyName = @"";
        childNode.className = className;
        if (!head) {
            head = childNode;
            node.childrens = head;
        } else {
            head.next = childNode;
            head = head.next;
        }
    }

    return node;
}

- (void)graphIfExistCycle:(TPFLinkedList *)head vertexs:(NSMutableDictionary *)vertexs {
    NSMutableArray *cyclePath = [[NSMutableArray alloc] init];
    [self dfs:head path:[NSMutableArray new] visited:[NSMutableDictionary new] cyclePath:cyclePath];
    if (cyclePath.count > 0) {
        NSLog(@"发现%ld处循环引用", cyclePath.count);
        NSLog(@"循环引用记录：\r\n%@", cyclePath);
        NSAssert(cyclePath.count > 0, @"发现%ld处循环引用", cyclePath.count);
    }
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
