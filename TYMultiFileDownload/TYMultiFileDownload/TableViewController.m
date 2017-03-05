//
//  ViewController.m
//  TYMultiFileDownload
//
//  Created by thomasTY on 16/11/20.
//  Copyright © 2016年 滕佳超. All rights reserved.
//

#import "TableViewController.h"
#import "Book.h"
#import "BookCell.h"
#import "DownloadManager.h"

@interface TableViewController () <UITableViewDataSource,BookCellDelegate>

@end

@implementation TableViewController
{
    /// 数据源数组
    NSArray *_bookList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadBookList];
}

/// 获取电子书列表数据的主方法
- (void)loadBookList
{
    NSURL *URL = [NSURL URLWithString:@"http://42.62.15.101/yyting/bookclient/ClientGetBookResource.action?bookId=30776&imei=OEVGRDQ1ODktRUREMi00OTU4LUE3MTctOUFGMjE4Q0JDMTUy&nwt=1&pageNum=1&pageSize=50&q=114&sc=acca7b0f8bcc9603c25a52f572f3d863&sortType=0&token=KMSKLNNITOFYtR4iQHIE2cE95w48yMvrQb63ToXOFc8%2A"];
    [[[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil && data != nil)
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSArray *list = result[@"list"];
            NSMutableArray *tmpM = [NSMutableArray arrayWithCapacity:list.count];
            [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                Book *book = [Book bookWithDict:obj];
                [tmpM addObject:book];
            }];
            _bookList = tmpM.copy;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
            
        } else
        {
            NSLog(@"%@",error);
        }
        
    }] resume];
}

#pragma UITableViewDataSource
///row
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _bookList.count;
}
///cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell" forIndexPath:indexPath];
    cell.delegate = self;
    Book *book = _bookList[indexPath.row];
    cell.book = book;
    
    return cell;
}
///下载按钮点击
- (void)downloadBtnClick:(BookCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Book *book = _bookList[indexPath.row];
    BOOL isDownloading = [[DownloadManager sharedManager] checkIsDownloadingWithURLString:book.path];
    
    if (!isDownloading)
    {
        [[DownloadManager sharedManager] downloadWithURLString:book.path progress:^(float progress) {
            NSLog(@"VC 进度 %zd -- %f",indexPath.row,progress);
            BookCell *updateCell = [self.tableView cellForRowAtIndexPath:indexPath];
            book.downloadProgress = progress;
            updateCell.book = book;
            
        } completion:^(NSString *filePath) {
            
            NSLog(@"VC 下载完成 %@",filePath);
            book.isSelected = !book.isSelected;
            //解决cell的复用问题
            BookCell *updateCell = [self.tableView cellForRowAtIndexPath:indexPath];
            updateCell.book = book;
        }];
    } else
    {
        [[DownloadManager sharedManager] pauseDownloadWithURLString:book.path pauseBlock:^{
            NSLog(@"暂停成功");
        }];
    }
}


@end
