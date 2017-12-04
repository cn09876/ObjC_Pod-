//
//  UIViewController+FrmTest.m
//  a1
//
//  Created by uosim on 2017/11/27.
//  Copyright © 2017年 ss. All rights reserved.
//

#import "FrmTest.h"
#import "SVProgressHUD.h"
#import "SwTool.h"

@interface FrmTest()

@end


@implementation FrmTest
- (IBAction)btn1_click:(id)sender {
    [SVProgressHUD showSuccessWithStatus:@"xxxxx"];
}

- (void)viewDidLoad {
    NSLog(@"Hi! I'm FrmTest");
    [super viewDidLoad];
}

@end
