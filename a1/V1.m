//
//  V1.m
//  a1
//
//  Created by uosim on 2017/12/1.
//  Copyright © 2017年 ss. All rights reserved.
//

#import "V1.h"

@implementation V1

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)btn1_clk:(id)sender {
    NSLog(@"aaa1");
}
- (IBAction)btn_2_clk:(id)sender {
    [self removeFromSuperview];
    NSLog(@"aaa2");
}

@end
