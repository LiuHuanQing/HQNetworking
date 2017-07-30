//
//  HQAPIManager.h
//  APIDemo
//
//  Created by 刘欢庆 on 2017/3/26.
//  Copyright © 2017年 刘欢庆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HQBaseAPI.h"
@interface HQAPIManager : NSObject
+ (instancetype __nullable)sharedInstance;

- (void)sendAPIRequest:(nonnull HQBaseAPI *)api;

- (void)cancelAPIRequest:(nonnull HQBaseAPI *)api;
@end
