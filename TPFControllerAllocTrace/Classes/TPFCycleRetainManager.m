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
}

- (TPFLinkedList *)findInstanceObject:(id)object vertexs:(NSMutableDictionary *)vertexs {
    TPFLinkedList *node = [[TPFLinkedList alloc] init];
    node.className = NSStringFromClass(object);
    node.address = [NSString stringWithFormat:@"%p", object];
    [vertexs setObject:node forKey:node.address];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([object class], &count);
    
    NSMutableDictionary *keyPathClassNames = [NSMutableDictionary new];
    
    unsigned i;
    for (i = 0; i < count; i++){
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        NSString* propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSArray* splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@"\""];
        if ([splitPropertyAttributes count] >= 2)
        {
            NSString *className = [splitPropertyAttributes objectAtIndex:1];
            [keyPathClassNames setValue:className forKey:propertyName];
            
            id propertyObject = [self valueForKey:propertyName];
            if(propertyObject != nil){

                if ([className isEqualToString:@"NSNumber"]) {    // 这个类型比较尴尬啊，初始化方法必须传入具体的数值
                    [self setValue:[NSNumber numberWithInt:0] forKey:propertyName];
                }
                else{
                    id class =[[NSClassFromString(className) alloc] init];
                    if(class)
                        [self setValue:class forKey:propertyName];
                }

            }
        }
    }
    
    free(properties);
    
    return node;
}

@end
