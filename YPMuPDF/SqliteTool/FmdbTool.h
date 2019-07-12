//
//  FmdbTool.h
//  YPMuPDFDemo
//
//  Created by navchina on 2017/8/3.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AnnotsModel;
@interface FmdbTool : NSObject


+(FmdbTool *)shareAnnotDB;

// 插入数据
- (void)insertIntoDataBaseWithModel:(AnnotsModel *)model;

// 查询数据
- (NSMutableArray *)selectAnnotsModelListFromDataBaseWithUUid:(NSString *)uuid andPageIndex:(NSInteger)pageIndex;

- (NSMutableArray *)selectAnnotsModelListFromDataBaseWithUUid:(NSString *)uuid;

//更新某一条数据，位置变了
-(void)updateDataBaseWithModel:(id)model withCurvesData:(NSData *)data WithAnnotRect:(NSString *)annotRect;

//当旋转方式变了，更新数据库中对应pdf的旋转方向
-(void)updateDataBaseWithUUId:(NSString *)uuid withRotation:(CGFloat)rotation;

//删除数据库中的某一条
-(void)deleteDataBaseWithAnnotModel:(id)model;
// 删除数据
- (void)deleteUserInfoListFromDataBase;

//获取数据库路径
-(NSString *)dataBasePath;
@end
