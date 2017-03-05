//
//  Book.m
//  TYMultiFileDownload
//
//  Created by thomasTY on 16/11/20.
//  Copyright © 2016年 滕佳超. All rights reserved.
//

#import "Book.h"

@implementation Book

+ (instancetype)bookWithDict:(NSDictionary *)dict
{
    Book *book = [[Book alloc] init];
    
    [book setValuesForKeysWithDictionary:dict];
    
    return book;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ -- %@",self.name,self.path];
}

@end
