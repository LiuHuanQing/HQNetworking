//
//  HQAPIUtils.h
//  APIDemo
//
//  Created by 刘欢庆 on 2017/3/26.
//  Copyright © 2017年 刘欢庆. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQAPIUtils : NSObject
+ (id)responseResult:(id)responseObject keyPath:(NSString *)keyPath ClassName:(NSString *)className;
@end
