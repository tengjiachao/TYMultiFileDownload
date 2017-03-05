//
//  Book.h
//  TYMultiFileDownload
//
//  Created by thomasTY on 16/11/20.
//  Copyright © 2016年 滕佳超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

/// 书名
@property (nonatomic,copy) NSString *name;
/// 音频下载地址
@property (nonatomic,copy) NSString *path;
/// 记录按钮的选中状态
@property (nonatomic,assign) BOOL isSelected;
/// 记录下载进度
@property (nonatomic,assign) float downloadProgress;

+ (instancetype)bookWithDict:(NSDictionary *)dict;

@end
