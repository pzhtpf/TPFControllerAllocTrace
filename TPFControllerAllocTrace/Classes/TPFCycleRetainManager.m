//
//  TPFCycleRetainManager.m
//  TPFControllerAllocTrace
//
//  Created by pengfei tian on 2022/4/17.
//

#import "TPFCycleRetainManager.h"
#import <objc/runtime.h>

@interface TPFCycleRetainManager ()

@property (strong, nonatomic) NSMutableDictionary *retainObjects;

@end

@implementation TPFCycleRetainManager

+ (instancetype)shared {
    static TPFCycleRetainManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TPFCycleRetainManager alloc] init];
    });
    return manager;
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
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([object class], &count);
    
    NSMutableDictionary *keyPathClassNames = [NSMutableDictionary new];
    
    unsigned i;
    for (i = 0; i < count; i++){
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        NSString* propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSLog(@"propertyAttributes: %@", propertyAttributes);
//        if ([propertyAttributes containsString:@"UIViewController"]) {
//
//        }
        NSArray* splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@"\""];
        if ([splitPropertyAttributes count] >= 2)
        {
            NSString *className = [splitPropertyAttributes objectAtIndex:1];
            [keyPathClassNames setValue:className forKey:propertyName];
            
            id propertyObject = [object valueForKey:propertyName];
            if(propertyObject != nil){
                
                NSString *modifier = [splitPropertyAttributes objectAtIndex:2];
                NSArray *modifierArray = [modifier componentsSeparatedByString:@","];
                if ([self isStrongRef:modifierArray]) {
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
                    }
                }
            }
        }
    }
    
    free(properties);
    return node;
}

- (BOOL)isStrongRef:(NSArray *)modifierArray {
    __block BOOL flag = false;
    [modifierArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < modifierArray.count -1 && [obj isEqualToString:@"&"]) {
            flag = true;
            *stop = YES;
        }
    }];
    return flag;
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
//        [path addObject:childHead];
//        [visited setObject:childHead forKey:childHead.address];
        [self dfs:childHead path:path visited:visited cyclePath:cyclePath];
//        [path removeLastObject];
//        [visited removeObjectForKey:childHead.address];
        childHead = childHead.next;
    }
    
    [path removeLastObject];
    [visited removeObjectForKey:head.address];
}

- (NSMutableArray *)serializeCyclePath:(NSMutableArray *)cyclePath {
    NSMutableArray *serializeArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < cyclePath.count; i++) {
        TPFLinkedList *node = cyclePath[i];
        NSString *string = [NSString stringWithFormat:@"ClassName=%@;PropertyName=%@;Address=%@",node.className,node.propertyName,node.address];
        [serializeArray addObject:string];
    }
    return serializeArray;
}

@end
