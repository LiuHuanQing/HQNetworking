//
//  HQAPIUtils.m
//  APIDemo
//
//  Created by 刘欢庆 on 2017/3/26.
//  Copyright © 2017年 刘欢庆. All rights reserved.
//

#import "HQAPIUtils.h"
#import "YYModel.h"
@implementation HQAPIUtils
+ (id)responseResult:(id)responseObject keyPath:(NSString *)keyPath ClassName:(NSString *)className
{
    if (keyPath == nil || keyPath.length == 0)
    {
        return responseObject;
    }
    
    NSArray *keys = [keyPath componentsSeparatedByString:@"/"];
    
    id result;
    id nodeObject = responseObject;
    for (NSString *key in keys)
    {
        if([key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length)
        {
            nodeObject = [nodeObject objectForKey:key];
            //节点取不到数据直接返回空
            if(!nodeObject)
                return nil;
        }
    }
    
    //类型为@"" 直接返回节点数据
    if(className.length == 0)
    {
        return nodeObject;
    }
    
    //无法识别的类型直接返回节点数据
    Class cls = NSClassFromString(className);
    if(cls == nil)
    {
        return nodeObject;
    }

    
    if([nodeObject isKindOfClass:[NSDictionary class]])
    {//节点为对象解析成对象
        result = [cls yy_modelWithDictionary:nodeObject];
    }
    else if([nodeObject isKindOfClass:[NSArray class]])
    {//节点为对象解析成对象数组
        NSMutableArray *tmpResult = [NSMutableArray arrayWithCapacity:[nodeObject count]];
        for (NSDictionary *dict in nodeObject)
        {
            id item = [cls yy_modelWithDictionary:dict];
            if(item)
            {
                [tmpResult addObject:item];
            }
        }
        result = tmpResult;
    }
    else
    {
        result = nodeObject;
    }

    
    return result;
}

@end
