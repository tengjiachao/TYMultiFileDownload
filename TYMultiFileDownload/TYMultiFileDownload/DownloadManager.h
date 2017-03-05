//
//  DownloadManager.h
//  TYMultiFileDownload
//
//  Created by thomasTY on 16/11/20.
//  Copyright © 2016年 滕佳超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadManager : NSObject

+ (instancetype)sharedManager;

/**
 *  单例下载的主方法
 *
 *  @param URLString       下载地址
 *  @param progressBlock   下载进度回调
 *  @param completionBlock 下载完成回调
 */
- (void)downloadWithURLString:(NSString *)URLString progress:(void(^)(float progress))progressBlock completion:(void(^)(NSString *filePath))completionBlock;

/**
 *  检查是否正在下载
 *
 *  @param URLString 下载地址
 *
 *  @return 返回是否正在下载
 */
- (BOOL)checkIsDownloadingWithURLString:(NSString *)URLString;

/**
 *  暂停下载的主方法
 *
 *  @param URLString 暂停下载的地址
 */
- (void)pauseDownloadWithURLString:(NSString *)URLString pauseBlock:(void(^)())pauseBlock;

@end
