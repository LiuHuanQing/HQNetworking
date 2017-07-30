//
//  HQAPIDefines.h
//  APIDemo
//
//  Created by 刘欢庆 on 2017/3/25.
//  Copyright © 2017年 刘欢庆. All rights reserved.
//

#ifndef HQAPIDefines_h
#define HQAPIDefines_h

#define HQ_API_REQUEST_TIME_OUT     15
typedef void (^HQAPICompleteHandler)(NSDictionary *result,NSError *error);

// 网络请求类型
typedef NS_ENUM(NSUInteger, HQRequestMethod) {
    HQRequestMethodGET     = 0,
    HQRequestMethodPOST    = 1,
    //**未实现**//
//    HQRequestMethodHEAD    = 2,
//    HQRequestMethodPUT     = 3,
//    HQRequestMethodPATCH   = 4,
    HQRequestMethodDELETE  = 5
};

// 请求的序列化格式
typedef NS_ENUM(NSUInteger, HQRequestSerializerType) {
    HQRequestSerializerTypeHTTP    = 0,
    HQRequestSerializerTypeJSON    = 1
};

// 请求返回的序列化格式
typedef NS_ENUM(NSUInteger, HQResponseSerializerType) {
    HQResponseSerializerTypeHTTP    = 0,
    HQResponseSerializerTypeJSON    = 1
};



#endif /* HQAPIDefines_h */
