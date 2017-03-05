//
//  BookCell.h
//  TYMultiFileDownload
//
//  Created by thomasTY on 16/11/20.
//  Copyright © 2016年 滕佳超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@class BookCell;

@protocol BookCellDelegate <NSObject>

- (void)downloadBtnClick:(BookCell *)cell;

@end

@interface BookCell : UITableViewCell

/// 接收VC传入的模型
@property (nonatomic,strong) Book *book;

/// 代理属性
@property (nonatomic,weak) id <BookCellDelegate> delegate;

@end
