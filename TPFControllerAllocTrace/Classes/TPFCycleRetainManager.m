//
//  TPFCycleRetainManager.m
//  TPFControllerAllocTrace
//
//  Created by pengfei tian on 2022/4/17.
//

#import "TPFCycleRetainManager.h"
#import "TPFRetainCycleDetector.h"
#import <objc/runtime.h>

@interface TPFCycleRetainManager ()

@property (strong, nonatomic) NSMutableDictionary *retainObjects;
@property (strong, nonatomic) NSLock *retainObjectLock;
@property (nonatomic) dispatch_queue_t retainCycleAnalyseQueue;

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

- (instancetype)init {
    self = [super init];
    if (self) {
        self.retainObjects = [[NSMutableDictionary alloc] init];
        self.retainObjectLock = [[NSLock alloc] init];
        self.retainCycleAnalyseQueue = dispatch_queue_create("com.tpf.retainCycleAnalyseQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma public API
- (void)analyse:(id)object {
    if (!object) return;
    
    dispatch_async(self.retainCycleAnalyseQueue, ^{
        [self retainObject:object];
        TPFRetainCycleDetector *retainCycleDetector = [[TPFRetainCycleDetector alloc] initWithObject:object];
        [self releaseObject:object];
    });
}

- (void)retainObject:(id)object {
    [self.retainObjectLock lock];
    [self.retainObjects setObject:object forKey:[NSString stringWithFormat:@"%p", object]];
    [self.retainObjectLock unlock];
}

- (void)releaseObject:(id)object {
    [self.retainObjectLock lock];
    [self.retainObjects removeObjectForKey:[NSString stringWithFormat:@"%p", object]];
    [self.retainObjectLock unlock];
}

@end
