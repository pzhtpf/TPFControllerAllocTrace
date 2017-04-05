//
//  TPFViewController.m
//  TPFControllerAllocTrace
//
//  Created by pzhtpf on 04/05/2017.
//  Copyright (c) 2017 pzhtpf. All rights reserved.
//

#import "TPFViewController.h"
#import "SecondViewController.h"
#import "TestAllocBlock.h"

@interface TPFViewController ()
@property(strong,nonatomic) TestAllocBlock *testAllocBlock;
@end

@implementation TPFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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


- (IBAction)goAction:(id)sender {
    
    SecondViewController *secondViewController = [[SecondViewController alloc] init];
    [self presentViewController:secondViewController animated:YES completion:^{
        
    }];
}

- (IBAction)goNavAction:(id)sender {
    
    SecondViewController *secondViewController = [[SecondViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:secondViewController];
    [self presentViewController:navigationController animated:YES completion:^{
        
    }];
}
@end
