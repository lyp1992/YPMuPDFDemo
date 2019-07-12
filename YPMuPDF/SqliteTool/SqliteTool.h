//
//  SqliteTool.h
//  YPMuPDFDemo
//
//  Created by navchina on 2017/8/2.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AnnotsModel;
@interface SqliteTool : NSObject
//存
/**
 
 存储联系人
 contact：联系人
 **/

+(void)saveWithContact:(AnnotsModel *)contact;

//取
/**
 
 获取联系人
 sql查询的语句
 **/

+(NSArray *)contactWithSql:(NSString *)sql;

+(NSArray *)annotModels;

@end
