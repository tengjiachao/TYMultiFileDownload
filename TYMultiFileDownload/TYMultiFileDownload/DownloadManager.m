//
//  DownloadManager.m
//  TYMultiFileDownload
//
//  Created by thomasTY on 16/11/20.
//  Copyright © 2016年 滕佳超. All rights reserved.
//

#import "DownloadManager.h"

@interface DownloadManager () <NSURLSessionDownloadDelegate>

@end

@implementation DownloadManager {
    
    /// 全局下载的session
    NSURLSession *_downloadSession;
    /// 进度回调缓存池
    NSMutableDictionary *_progressBlockDict;
    /// 完成回调缓存池
    NSMutableDictionary *_completionBlockDict;
    /// 下载任务缓存池
    NSMutableDictionary *_downlaodTaskDict;
}

+ (instancetype)sharedManager
{
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"HM"];
        _downloadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        // 实例化进度回调缓存池 / 完成回调缓存池 / 下载任务缓存池
        _progressBlockDict = [[NSMutableDictionary alloc] init];
        _completionBlockDict = [[NSMutableDictionary alloc] init];
        _downlaodTaskDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/// 单例下载的主方法
- (void)downloadWithURLString:(NSString *)URLString progress:(void (^)(float))progressBlock completion:(void (^)(NSString *))completionBlock
{
    NSURL *URL = [NSURL URLWithString:URLString];
    NSData *resumeData = [NSData dataWithContentsOfFile:[self appendTempPath:URLString]];
    NSURLSessionDownloadTask *downloadTask;
    if (resumeData != nil)
    {
        downloadTask = [_downloadSession downloadTaskWithResumeData:resumeData];
        // 移除续使用完的传数据
        [[NSFileManager defaultManager] removeItemAtPath:[self appendTempPath:URLString] error:NULL];
    } else
    {
        downloadTask = [_downloadSession downloadTaskWithURL:URL];
    }
    [_progressBlockDict setObject:progressBlock forKey:downloadTask];
    [_completionBlockDict setObject:completionBlock forKey:downloadTask];
    [_downlaodTaskDict setObject:downloadTask forKey:URLString];
    [downloadTask resume];
}

/// 判断是否正在下载
- (BOOL)checkIsDownloadingWithURLString:(NSString *)URLString
{
    if ([_downlaodTaskDict objectForKey:URLString] != nil)
    {
        return YES;
    }
    return NO;
}

/// 暂停下载的主方法
- (void)pauseDownloadWithURLString:(NSString *)URLString pauseBlock:(void (^)())pauseBlock
{
    NSURLSessionDownloadTask *downloadTask = [_downlaodTaskDict objectForKey:URLString];
    if (downloadTask)
    {
        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            [resumeData writeToFile:[self appendTempPath:URLString] atomically:YES];
            [_progressBlockDict removeObjectForKey:downloadTask];
            [_completionBlockDict removeObjectForKey:downloadTask];
            [_downlaodTaskDict removeObjectForKey:URLString];

            if (pauseBlock)
            {
                pauseBlock();
            }
        }];
    }
}

#pragma - NSURLSessionDownloadDelegate

/// 监听文件下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    void (^progressBlock)(float) = [_progressBlockDict objectForKey:downloadTask];
    if (progressBlock)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            progressBlock(progress);
        }];
    }
}

/// 监听文件下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSString *URLString = downloadTask.currentRequest.URL.absoluteString;
    NSString *fileName = [URLString lastPathComponent];
    NSString *savePath = [NSString stringWithFormat:@"/Users/xiele/Desktop/%@",fileName];
    [[NSFileManager defaultManager] copyItemAtPath:location.path toPath:savePath error:NULL];

    void(^completionBlock)(NSString *) = [_completionBlockDict objectForKey:downloadTask];
    if (completionBlock)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(savePath);
        }];
    }
    
    // 下载完成后缓存池清空
    [_progressBlockDict removeObjectForKey:downloadTask];
    [_completionBlockDict removeObjectForKey:downloadTask];
    [_downlaodTaskDict removeObjectForKey:URLString];
}

/// 获取tmp文件缓存路径
- (NSString *)appendTempPath:(NSString *)string
{
    NSString *path = NSTemporaryDirectory();
    NSString *name = [string lastPathComponent];
    NSString *filePath = [path stringByAppendingPathComponent:name];
    return filePath;
}

@end
