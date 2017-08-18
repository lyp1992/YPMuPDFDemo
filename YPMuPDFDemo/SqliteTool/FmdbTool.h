//
//  FmdbTool.h
//  YPMuPDFDemo
//
//  Created by navchina on 2017/8/3.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AnnotsModel;
@interface FmdbTool : NSObject

+(FmdbTool *)shareAnnotDB;

// 插入数据
- (void)insertIntoDataBaseWithModel:(AnnotsModel *)model;
//查询数据
// 查询数据
- (NSMutableArray *)selectAnnotsModelListFromDataBase;
// 删除数据
- (void)deleteUserInfoListFromDataBase;

//更新某一条数据
-(void)updateDataBaseWithModel:(id)model withCurvesData:(NSData *)data WithAnnotRect:(NSString *)annotRect;
//删除数据库中的某一条
-(void)deleteDataBaseWithAnnotModel:(id)model;

//获取数据库路径
-(NSString *)dataBasePath;
@end
