//
//  HQBaseAPI.m
//  APIDemo
//
//  Created by 刘欢庆 on 2017/3/25.
//  Copyright © 2017年 刘欢庆. All rights reserved.
//

#import "HQBaseAPI.h"
#import "HQAPIManager.h"
@interface HQBaseAPI()
{
    HQAPICompleteHandler _completeHandler;
    NSUInteger _identifier;
    HQRequestConstructingBodyBlock _constructingBodyBlock;
    HQProgressBlock _progressBlock;
    __weak id <HQAOPDelegate> _aopDelegate;
}
@end
@implementation HQBaseAPI

- (void)setAopDelegate:(id<HQAOPDelegate>)aopDelegate
{
    _aopDelegate = aopDelegate;
}

- (id<HQAOPDelegate>)aopDelegate
{
    return _aopDelegate;
}

- (NSString *)baseURL
{
    return @"";
}

- (NSString *)requestURL
{
    return @"";
}

- (HQRequestMethod)requestMethod
{
    return HQRequestMethodGET;
}

- (HQRequestSerializerType)requestSerializerType
{
    return HQRequestSerializerTypeJSON;
}

- (HQResponseSerializerType)responseSerializerType
{
    return HQResponseSerializerTypeJSON;
}

- (NSDictionary *)requestParams
{
    return @{};
}

- (NSDictionary *)HTTPHeaderFields
{
    return @{};
}

- (NSDictionary *)extraHTTPHeaderFields
{
    return @{};
}


- (NSDictionary *)responseResultMapping
{
    return @{};
}

- (NSDictionary *)extraResponseResultMapping
{
    return @{};
}

- (NSTimeInterval)requestTimeoutInterval
{
    return HQ_API_REQUEST_TIME_OUT;
}


- (nullable NSSet *)responseAcceptableContentTypes
{
    return [NSSet setWithObjects:
            @"text/json",
            @"text/html",
            @"application/json",
            @"text/javascript", nil];
}

- (void)setCompleteHandler:(HQAPICompleteHandler)completeHandler
{
    _completeHandler = completeHandler;
}

- (__nullable HQAPICompleteHandler)completeHandler
{
    return _completeHandler;
}

- (void)setConstructingBodyBlock:(HQRequestConstructingBodyBlock)constructingBodyBlock
{
    _constructingBodyBlock = constructingBodyBlock;
}

- (__nullable HQRequestConstructingBodyBlock)constructingBodyBlock
{
    return _constructingBodyBlock;
}

- (void)setProgressBlock:(HQProgressBlock)progressBlock
{
    _progressBlock = progressBlock;
}

- (__nullable HQProgressBlock)progressBlock
{
    return _progressBlock;
}


- (NSUInteger)identifier
{
    return _identifier;
}

- (void)setIdentifier:(NSUInteger)identifier
{
    _identifier = identifier;
}

- (BOOL)mainThreadCompleteHandler
{
    return YES;
}

- (void)start
{
    [[HQAPIManager sharedInstance] sendAPIRequest:self];
}

- (void)stop
{
    [[HQAPIManager sharedInstance] cancelAPIRequest:self];
}
@end

