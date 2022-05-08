//
//  TPFControllerAllocTrace.m
//  TPFControllerAllocTrace
//
//  Created by Roc.Tian on 2017/4/5.
//  Copyright © 2017年 Roc.Tian. All rights reserved.
//

#import "TPFControllerAllocTrace.h"
#import <Aspects/Aspects.h>
#import "TPFCycleRetainManager.h"

@interface TPFControllerAllocTrace ()

@property (strong, nonatomic) NSMutableDictionary *controllersDictionary;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) float duration;

@end

@implementation TPFControllerAllocTrace

+ (instancetype)sharedControllerAllocTrace {
    static TPFControllerAllocTrace *controllerAllocTrace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controllerAllocTrace = [[TPFControllerAllocTrace alloc]init];
    });
    return controllerAllocTrace;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = 5.0f;
        _controllersDictionary = [[NSMutableDictionary alloc] init];
        [self initTraceMethod];
    }
    return self;
}

- (void)initTraceMethod {
    NSError *error;
    __weak typeof(self) weakSlef = self;
    [UIViewController aspect_hookSelector:@selector(dismissViewControllerAnimated:completion:)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id <AspectInfo> aspectInfo) {
                                   UIViewController *viewController = aspectInfo.instance;
                                   [weakSlef findCycleRetain:viewController];
                               }
                                    error:&error];

    SEL sel = NSSelectorFromString(@"dealloc");
    [UIViewController aspect_hookSelector:sel withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
        UIViewController *viewController = aspectInfo.instance;
        NSString *className = NSStringFromClass([viewController class]);
        [weakSlef removeClassObserve:className];
        if (weakSlef.controllersDictionary.count == 0) {
            [self invalidateTimer];
        }
        NSLog(@"%@ dealloc", className);
    } error:NULL];

    [UINavigationController aspect_hookSelector:@selector(popViewControllerAnimated:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
        UINavigationController *navigationController = aspectInfo.instance;
        NSArray *viewControllers = [navigationController viewControllers];
        UIViewController *viewController = viewControllers.lastObject;
        [weakSlef findCycleRetain:viewController];
    } error:NULL];
}

- (void)findCycleRetain:(id)object {
    NSString *className = NSStringFromClass([object class]);
    if ([self.exclusiveClass containsObject:className]) return;

    [[TPFCycleRetainManager shared] analyse:object];
    NSTimeInterval startTime = [[NSDate new] timeIntervalSince1970];
    [self.controllersDictionary setValue:@(startTime) forKey:className];
    [self startTimer];
}

- (void)removeClassObserve:(NSString *)className {
    [self.controllersDictionary removeObjectForKey:className];
}

- (void)startTimer {
    if (!self.timer && self.controllersDictionary.count > 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.duration target:self selector:@selector(noAllocWaring:) userInfo:nil repeats:YES];
    }
}

- (void)invalidateTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)noAllocWaring:(NSTimer *)timer {
    NSTimeInterval currentTime = [[NSDate new] timeIntervalSince1970];
    NSMutableArray *removeKeys = [[NSMutableArray alloc] init];
    [self.controllersDictionary enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        NSTimeInterval startTime = [obj doubleValue];
        if (currentTime - startTime > self.duration) {
            [removeKeys addObject:key];
            NSString *warningMessage = [NSString stringWithFormat:@"%@ 没有被释放，请检查是否发生了泄漏，循环引用。测试人员请注意，督促相关人员修复", key];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:warningMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
#pragma clang diagnostic pop
        }
    }];
    [self.controllersDictionary removeObjectsForKeys:removeKeys];
    if (self.controllersDictionary.count == 0) {
        [self invalidateTimer];
    }
}

@end
