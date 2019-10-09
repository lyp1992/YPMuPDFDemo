//
//  PreferencesTool.h
//  EFBMuPDF
//
//  Created by 赖永鹏 on 2018/11/14.
//  Copyright © 2018年 赖永鹏. All rights reserved.
//

//偏好设置

#import <UIKit/UIKit.h>
@class PreferencesModel;
@interface PreferencesTool : NSObject

+(PreferencesTool *)shareAnnotDB;

// 插入数据
- (void)insertIntoDataBaseWithModel:(PreferencesModel *)model;

// 查询数据
- (NSMutableArray *)selectPreferencesModelListFromDataBaseWithUUid:(NSString *)uuid;

//当旋转方式变了，更新数据库中对应pdf的旋转方向
-(void)updateDataBaseWithUUId:(NSString *)uuid withRotation:(CGFloat)rotation;
-(BOOL)updateDBWithSql:(NSString *)sql;

// 删除数据
- (void)deleteUserInfoListFromDataBase;

//获取数据库路径
-(NSString *)dataBasePath;

@end
