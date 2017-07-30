//
//  PostImgAPI.h
//  APIDemo
//
//  Created by 刘欢庆 on 2017/6/12.
//  Copyright © 2017年 刘欢庆. All rights reserved.
//

#import "HQBaseAPI.h"
#import <UIKit/UIImage.h>

@interface PostImgAPI : HQBaseAPI

- (NSString *)formDataName;
- (NSString *)formDataFileName;
- (NSString *)formDataMimeType;

- (void)addImage:(UIImage *)image;
- (void)addImageData:(NSData *)imageData;
@end
