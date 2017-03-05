//
//  BookCell.m
//  TYMultiFileDownload
//
//  Created by thomasTY on 16/11/20.
//  Copyright © 2016年 滕佳超. All rights reserved.
//

#import "BookCell.h"
@interface BookCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation BookCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // 创建右侧下载按钮
    UIButton *downloadBtn = [[UIButton alloc] init];
    [downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
    [downloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [downloadBtn setTitle:@"暂停" forState:UIControlStateSelected];
    [downloadBtn sizeToFit];
    self.accessoryView = downloadBtn;
    [downloadBtn addTarget:self action:@selector(downloadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

/// 下载按钮点击事件
- (void)downloadBtnClick:(UIButton *)btn
{
    self.book.isSelected = !self.book.isSelected;
    NSString *title = (self.book.isSelected == YES) ? @"暂停" : @"下载";
    [btn setTitle:title forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(downloadBtnClick:)])
    {
        [self.delegate downloadBtnClick:self];
    }
}

- (void)setBook:(Book *)book
{
    _book = book;    
    // 解决cell滚动时,按钮状态复用
    UIButton *btn = (UIButton *)self.accessoryView;
    NSString *title = (self.book.isSelected == YES) ? @"暂停" : @"下载";
    [btn setTitle:title forState:UIControlStateNormal];
    self.nameLabel.text = book.name;
    self.progressView.progress = book.downloadProgress;
}

@end
