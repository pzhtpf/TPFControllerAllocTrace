//
//  TPFControllerAllocTrace.m
//  TPFControllerAllocTrace
//
//  Created by Roc.Tian on 2017/4/5.
//  Copyright © 2017年 Roc.Tian. All rights reserved.
//

#import "TPFControllerAllocTrace.h"
#import <Aspects/Aspects.h>

@interface TPFControllerAllocTrace ()

@property(strong,nonatomic) NSMutableDictionary *controllersDictionary;

@end

@implementation TPFControllerAllocTrace

+(instancetype)sharedControllerAllocTrace{

    static TPFControllerAllocTrace *controllerAllocTrace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controllerAllocTrace = [[TPFControllerAllocTrace alloc]init];
    });
    return controllerAllocTrace;
}
-(instancetype)init{

    self = [super init];
    if(self){
    
        _controllersDictionary = [[NSMutableDictionary alloc] init];
        [self initTraceMethod];
    }
    return self;
}
-(void)initTraceMethod{

    NSError *error;
    __weak typeof(self) weakSlef = self;
    [UIViewController aspect_hookSelector:@selector(dismissViewControllerAnimated:completion:)
                             withOptions:AspectPositionAfter
                              usingBlock:^(id <AspectInfo> aspectInfo){
                                  UIViewController *viewController = aspectInfo.instance;
                                  NSString *className = [NSString stringWithFormat:@"%s",object_getClassName(viewController)];
                                  [weakSlef.controllersDictionary setValue:[self startTimer:className] forKey:className];
                              }
                                   error:&error];
    
    SEL sel = NSSelectorFromString(@"dealloc");
    [UIViewController aspect_hookSelector:sel withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
        
        UIViewController *viewController = aspectInfo.instance;
        NSString *className = [NSString stringWithFormat:@"%s",object_getClassName(viewController)];
        [weakSlef invalidateTimer:className];
        
        NSLog(@"%@ dealloc",className);
        
    } error:NULL];
    
    [UINavigationController aspect_hookSelector:@selector(popViewControllerAnimated:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
        
        UINavigationController *navigationController = aspectInfo.instance;
        NSArray *viewControllers = [navigationController viewControllers];
        UIViewController  *viewController = viewControllers.lastObject;
        NSString *className = [NSString stringWithFormat:@"%s",object_getClassName(viewController)];
       [weakSlef.controllersDictionary setValue:[self startTimer:className] forKey:className];
        
    } error:NULL];

}
-(NSTimer *)startTimer:(NSString *)className{

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(noAllocWaring:) userInfo:@{@"className":className} repeats:NO];
    
    return timer;
}
-(void)invalidateTimer:(NSString *)className{

    NSTimer *timer = [self.controllersDictionary valueForKey:className];
    [timer invalidate];
    [self.controllersDictionary removeObjectForKey:className];
    timer = nil;
}
-(void)noAllocWaring:(NSTimer *)timer{

    NSDictionary *userInfo = timer.userInfo;
    NSString *className = [userInfo valueForKey:@"className"];
    NSString *warningMessage = [NSString stringWithFormat:@"%@ 没有被释放，请检查是否发生了泄漏",className];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:warningMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    
    [self invalidateTimer:className];
}
@end
