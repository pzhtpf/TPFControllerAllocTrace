//
//  SecondViewController.m
//  TPFControllerAllocTrace
//
//  Created by Roc.Tian on 2017/4/5.
//  Copyright © 2017年 Roc.Tian. All rights reserved.
//

#import "SecondViewController.h"
#import "TestAllocBlock.h"
#import "TPFViewController.h"

@interface SecondViewController ()

@property(strong,nonatomic) TestAllocBlock *testAllocBlock;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.testAllocBlock = [TestAllocBlock new];
    self.testAllocBlock.testAllocBlock  = ^{
    
        [self loadData];
    };
}
-(void)loadData{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)pushAction:(id)sender {
    
    TPFViewController *viewController = [[TPFViewController alloc] init];
    viewController.view.backgroundColor = [UIColor lightGrayColor];
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
