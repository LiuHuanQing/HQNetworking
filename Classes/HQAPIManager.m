//
//  HQAPIManager.m
//  APIDemo
//
//  Created by 刘欢庆 on 2017/3/26.
//  Copyright © 2017年 刘欢庆. All rights reserved.
//

#import "HQAPIManager.h"
#import "AFHTTPSessionManager.h"
#import "HQAPIUtils.h"
#import "YYModel.h"

static NSString *specialCharacters = @"/?&.";

@interface HQAPIManager()
@property (nonatomic, strong) NSCache *sessionManagers;
@property (nonatomic, strong) NSMutableDictionary *sessionTasks;
@property (nonatomic, strong) dispatch_queue_t completionQueue;
@property (nonatomic, strong) dispatch_queue_t apiTaskCreateQueue;
@end
@implementation HQAPIManager
+ (instancetype)sharedInstance
{
    static HQAPIManager *_sharedInstance;
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - 系统
- (instancetype)init
{
    self = [super init];
    if(self)
    {
        //初始化
        _sessionManagers = [[NSCache alloc] init];
        _sessionTasks = [NSMutableDictionary dictionary];
        _completionQueue = dispatch_queue_create("com.liuhuanqing.api.completion",NULL);
        _apiTaskCreateQueue = dispatch_queue_create("com.liuhuanqing.api.create",DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - 初始化
- (AFHTTPRequestSerializer *)requestSerializerWithAPI:(HQBaseAPI *)api
{
    AFHTTPRequestSerializer *requestSerializer;
    if ([api requestSerializerType] == HQRequestSerializerTypeJSON)
    {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    else
    {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    requestSerializer.timeoutInterval = api.requestTimeoutInterval;
    NSDictionary *HTTPHeaderFields = [api HTTPHeaderFields];
    if (HTTPHeaderFields)
    {
        [HTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             [requestSerializer setValue:obj forHTTPHeaderField:key];
         }];
    }
    
    NSDictionary *extraHTTPHeaderFields = [api extraHTTPHeaderFields];
    if (extraHTTPHeaderFields)
    {
        [extraHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             [requestSerializer setValue:obj forHTTPHeaderField:key];
         }];
    }
    
    return requestSerializer;
}

- (AFHTTPResponseSerializer *)responseSerializerWithAPI:(HQBaseAPI *)api
{
    AFHTTPResponseSerializer *responseSerializer;
    if ([api responseSerializerType] == HQResponseSerializerTypeHTTP)
    {
        responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    else
    {
        responseSerializer = [AFJSONResponseSerializer serializer];
    }
    responseSerializer.acceptableContentTypes = [api responseAcceptableContentTypes];
    return responseSerializer;
}

- (NSURL *)baseURLWithAPI:(HQBaseAPI *)api
{
    return [NSURL URLWithString:@"/" relativeToURL:[NSURL URLWithString:api.baseURL]];
}

- (AFHTTPSessionManager *)sessionManagerWithBaseURL:(NSURL *)baseURL
{
    
    AFHTTPSessionManager *sessionManager = [self.sessionManagers objectForKey:baseURL.absoluteString];
    if(!sessionManager)
    {
        sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        [self.sessionManagers setObject:sessionManager forKey:baseURL.absoluteString];
        sessionManager.completionQueue = self.completionQueue;
    }
    return sessionManager;
}

- (void)_sendAPIRequest:(HQBaseAPI *)api
{
    NSParameterAssert(api);
    //生成请求序列化方法
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerWithAPI:api];
    
    //生成响应响应序列化方法
    AFHTTPResponseSerializer *responseSerializer = [self responseSerializerWithAPI:api];
    
    //生成请求域
    NSURL *baseURL = [self baseURLWithAPI:api];
    
    //生成SessionManager
    AFHTTPSessionManager *sessionManager = [self sessionManagerWithBaseURL:baseURL];
    sessionManager.requestSerializer     = requestSerializer;
    sessionManager.responseSerializer    = responseSerializer;
    
    //成功回调
    void (^successBlock)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask * task, id responseObject){
        [self.sessionTasks removeObjectForKey:@(task.taskIdentifier)];
        NSError *error;
        if([api.aopDelegate respondsToSelector:@selector(api:willSuccCompleteResponse:error:)])
        {
            [api.aopDelegate api:api willSuccCompleteResponse:responseObject error:&error];
        }
        
        if(error) { [self apiCompleteHandler:api responseObject:nil error:error]; return; }
        
        id result = responseObject;
        
        NSMutableDictionary *responseResultMapping = [NSMutableDictionary dictionaryWithCapacity:api.responseResultMapping.count+api.extraResponseResultMapping.count];
        [responseResultMapping addEntriesFromDictionary:api.responseResultMapping];
        [responseResultMapping addEntriesFromDictionary:api.extraResponseResultMapping];

        if([api.aopDelegate respondsToSelector:@selector(api:resultForResponse:error:)])
        {
            result = [api.aopDelegate api:api resultForResponse:responseObject error:&error];
            
            if(error) { [self apiCompleteHandler:api responseObject:nil error:error]; return; }
        }
        else if([responseResultMapping count])
        {
            result = [NSMutableDictionary dictionaryWithCapacity:[responseResultMapping count]];
            [responseResultMapping enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                id nodeResult = [HQAPIUtils responseResult:responseObject keyPath:key ClassName:obj];
                if(nodeResult)
                {
                    [result setObject:nodeResult forKey:key];
                }
            }];
        }
        
        [self apiCompleteHandler:api responseObject:result error:error];
        
    };
    
    void (^failureBlock)(NSURLSessionDataTask * task, NSError * error) = ^(NSURLSessionDataTask * task, NSError * error) {
        [self.sessionTasks removeObjectForKey:@(api.identifier)];
        
        if([api.aopDelegate respondsToSelector:@selector(api:willFailCompleteResponse:error:)])
        {
            NSData *data = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
            [api.aopDelegate api:api willFailCompleteResponse:data error:&error];
        }
        
        [self apiCompleteHandler:api responseObject:nil error:error];
    };
    
    NSDictionary *requestParams = [api requestParams];
    if(requestParams.count == 0)
    {
        requestParams = [api yy_modelToJSONObject];
    }
    
    NSString *requestURL = [api requestURL];
    
    //处理Resuful Url
    NSMutableDictionary *tmpRequestParams = [requestParams mutableCopy];
    NSString *newRequestURL = [requestURL copy];
    NSMutableArray *placeholders = [NSMutableArray array];
    NSInteger startIndexOfColon = 0;
    for (int i = 0; i < requestURL.length; i++)
    {
        NSString *character = [NSString stringWithFormat:@"%c", [requestURL characterAtIndex:i]];
        if ([character isEqualToString:@":"]) {
            startIndexOfColon = i;
        }
        if ([specialCharacters rangeOfString:character].location != NSNotFound && i > (startIndexOfColon + 1) && startIndexOfColon) {
            NSRange range = NSMakeRange(startIndexOfColon, i - startIndexOfColon);
            NSString *placeholder = [requestURL substringWithRange:range];
            if (![self checkIfContainsSpecialCharacter:placeholder]) {
                [placeholders addObject:placeholder];
                startIndexOfColon = 0;
            }
        }
        if (i == requestURL.length - 1 && startIndexOfColon) {
            NSRange range = NSMakeRange(startIndexOfColon, i - startIndexOfColon + 1);
            NSString *placeholder = [requestURL substringWithRange:range];
            if (![self checkIfContainsSpecialCharacter:placeholder]) {
                [placeholders addObject:placeholder];
            }
        }
    }
    for (NSString *ph in placeholders)
    {
        NSString *key = [ph substringFromIndex:1];
        NSString *val = [NSString stringWithFormat:@"%@",requestParams[key]];
        newRequestURL = [newRequestURL stringByReplacingOccurrencesOfString:ph withString:val];
        [tmpRequestParams removeObjectForKey:key];
    }
    requestURL = newRequestURL;
    requestParams = [tmpRequestParams copy];
    NSURLSessionDataTask *dataTask = nil;
    switch ([api requestMethod])
    {
        case HQRequestMethodGET:
        {
            dataTask = [sessionManager GET:requestURL parameters:requestParams progress:nil success:successBlock failure:failureBlock];
        }
            break;
        case HQRequestMethodPOST:
        {
            if(![api constructingBodyBlock])
            {
                dataTask = [sessionManager POST:requestURL parameters:requestParams progress:api.progressBlock success:successBlock failure:failureBlock];
            }
            else
            {
                void (^block)(id <AFMultipartFormData> formData)
                = ^(id <AFMultipartFormData> formData) {
                    api.constructingBodyBlock((id<HQMultipartFormData>)formData);
                };
                dataTask = [sessionManager POST:requestURL parameters:requestParams constructingBodyWithBlock:block progress:api.progressBlock success:successBlock failure:failureBlock];
            }
            
        }
            break;
        case HQRequestMethodDELETE:
        {
            dataTask = [sessionManager DELETE:requestURL parameters:requestParams success:successBlock failure:failureBlock];
        }
            break;
    }
    [api setIdentifier:dataTask.taskIdentifier];
    [self.sessionTasks setObject:dataTask forKey:@(dataTask.taskIdentifier)];
}
#pragma mark - 公共
- (void)apiCompleteHandler:(HQBaseAPI *)api responseObject:(id)responseObject error:(NSError *)error
{
    if(api.mainThreadCompleteHandler && ![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(api.completeHandler)api.completeHandler(responseObject,error);
        });
    }
    else
    {
        if(api.completeHandler)api.completeHandler(responseObject,error);
    }
}

- (void)sendAPIRequest:(HQBaseAPI *)api
{
    dispatch_async(_apiTaskCreateQueue, ^{
        [self _sendAPIRequest:api];
    });
}

- (void)cancelAPIRequest:(HQBaseAPI *)api
{
    dispatch_async(_apiTaskCreateQueue, ^{
        NSURLSessionDataTask *dataTask = [self.sessionTasks objectForKey:@(api.identifier)];
        [dataTask cancel];
    });
}

- (BOOL)checkIfContainsSpecialCharacter:(NSString *)checkedString {
    NSCharacterSet *specialCharactersSet = [NSCharacterSet characterSetWithCharactersInString:specialCharacters];
    return [checkedString rangeOfCharacterFromSet:specialCharactersSet].location != NSNotFound;
}
#pragma mark - getter
- (NSCache *)sessionManagers
{
    if (!_sessionManagers)
    {
        _sessionManagers = [[NSCache alloc] init];
    }
    return _sessionManagers;
}

- (NSMutableDictionary *)sessionTasks
{
    if(!_sessionTasks)
    {
        _sessionTasks = [NSMutableDictionary dictionary];
    }
    return _sessionTasks;
}

- (dispatch_queue_t)completionQueue
{
    if(!_completionQueue)
    {
        _completionQueue = dispatch_queue_create("com.liuhuanqing.api",NULL);
    }
    return _completionQueue;
}

@end
