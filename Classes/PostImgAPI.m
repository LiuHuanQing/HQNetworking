//
//  PostImgAPI.m
//  APIDemo
//
//  Created by 刘欢庆 on 2017/6/12.
//  Copyright © 2017年 刘欢庆. All rights reserved.
//

#import "PostImgAPI.h"
#import <UIKit/UIImage.h>
@interface PostImgAPI()
{
    NSMutableArray *_imageDatas;
}
@end

@implementation PostImgAPI
- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _imageDatas = [NSMutableArray array];
    }
    return self;
}

- (HQRequestMethod)requestMethod
{
    return HQRequestMethodPOST;
}

- (NSString *)formDataName
{
    return @"image";
}

- (NSString *)formDataFileName
{
    return @"image.jpeg";
}

- (NSString *)formDataMimeType
{
    return @"image/jpeg";
}


- (void)addImage:(UIImage *)image
{
    if(image == nil) return;
    NSData *data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
    [self addImageData:data];
}

- (void)addImageData:(NSData *)imageData
{
    if(imageData == nil) return;
    [_imageDatas addObject:imageData];
}


- (void)start
{
    if(_imageDatas.count == 0)
    {
        if(self.completeHandler)self.completeHandler(nil,[NSError errorWithDomain:@"图片上传没有数据" code:-1 userInfo:nil]);
        return;
    }
    NSString *formDataName = [self formDataName];
    NSString *formDataFileName = [self formDataFileName];
    NSString *formDataMimeType = [self formDataMimeType];
    
    __weak NSMutableArray *_weak_imageDatas = _imageDatas;
    [self setConstructingBodyBlock:^(id<HQMultipartFormData>  _Nonnull formData) {
        for (NSData *data in _weak_imageDatas)
        {
            [formData appendPartWithFileData:data name:formDataName fileName:formDataFileName mimeType:formDataMimeType];
        }
    }];
    [super start];
}

@end
