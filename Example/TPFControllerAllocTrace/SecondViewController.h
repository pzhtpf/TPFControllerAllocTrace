//
//  SecondViewController.h
//  TPFControllerAllocTrace
//
//  Created by Roc.Tian on 2017/4/5.
//  Copyright © 2017年 Roc.Tian. All rights reserved.
//

#import <UIKit/UIKit.h>

struct CycleRetainTest {
    NSDate *cycleRetainTestDate;
};

struct BlockLiteralTest {
    UIViewController *reserved;
    UIView *structView;
    struct CycleRetainTest *cycleRetainTest;
};

@interface SecondViewController : UIViewController {
    struct BlockLiteralTest blockLiteralTest;
}

- (IBAction)closeAction:(id)sender;
- (IBAction)pushAction:(id)sender;

@end
