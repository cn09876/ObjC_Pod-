//
//  SwTool.m
//  a1
//
//  Created by uosim on 2017/11/27.
//  Copyright © 2017年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SwTool.h"

@interface SwTool（）
@property (nonatomic, strong) NSString *str1;
@end

@implementation SwTool

-(NSString*)getVer
{
    return @"123456";
}

+(instancetype)initWithMiao
{
    return [[[self class] alloc] init];
}

@end

