//
//  SqliteTool.m
//  YPMuPDFDemo
//
//  Created by navchina on 2017/8/2.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "SqliteTool.h"
#import <sqlite3.h>
#import "AnnotsModel.h"
@implementation SqliteTool
/*
 打开数据库，第一次使用这个业务类
 创建表格
 */
static sqlite3 *_db;
+(void)initialize{
    
    //    保存沙盒地址
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    //    拼接文件名
    NSString *filePath = [cachePath stringByAppendingPathComponent:@"AnnotsModel.db"];
    
    
    NSLog(@"%@",NSHomeDirectory());
    //    打开数据库
    if (sqlite3_open(filePath.UTF8String, &_db)== SQLITE_OK) {
        NSLog(@"打开成功");
        
    }else{
        
        NSLog(@"打开失败");
    }
    //    创建失败
    NSString *sql = @"create table if not exists annotsModel (id integer primary key autoincrement,pageIndex integer,key text,curvesData blob,firstPoint text,lastPoint text,annotRect text)";
    char *error;
    sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    
    if (error) {
        NSLog(@"创建表格失败%s",error);
        
    }else{
        
        NSLog(@"创建表格成功");
    }
    
}

+(BOOL)exectWithSql:(NSString *)sql{
    
    BOOL flag;
    char *error;
    sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    if (error) {
        
        flag = NO;
        NSLog(@"%s",error);
    }else{
        
        flag = YES;
    }
    return flag;
}

+(void)saveWithContact:(AnnotsModel *)annotsM{
    
    NSString *sql = [NSString stringWithFormat:@"insert into annotsModel (pageIndex,curvesData,key,firstPoint,lastPoint,annotRect) values ('%ld','%@','%@','%@','%@','%@')",(long)annotsM.pageIndex,annotsM.curvesData,annotsM.key,annotsM.firstPoint,annotsM.lastPoint,annotsM.annotRect];
    
    BOOL flag = [self exectWithSql:sql];
    if (flag) {
        NSLog(@"插入成功");
    }else{
        
        NSLog(@"插入失败");
    }
    
}


+(NSArray *)annotModels{
    
    return [self contactWithSql:@"select *from annotsModel"];
    
}
+(NSArray *)contactWithSql:(NSString *)sql{
    
    NSMutableArray *arrM = [NSMutableArray array];
    //    准备查询,生成句柄，操作查询数据结果
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL)==SQLITE_OK) {
        
        //执行句柄
        while (sqlite3_step(stmt)==SQLITE_ROW) {
        //page
            NSInteger pageIndex = sqlite3_column_int(stmt, 1);
            //key
            NSString *key = [NSString stringWithFormat:@"%s",(const char *)sqlite3_column_text(stmt, 2)];
            
            //data
            int size = sqlite3_column_bytes(stmt, 3);
            NSData *curvesDa = [NSData dataWithBytes:(const char*)sqlite3_column_blob(stmt, 3) length:size];
            //key
            NSString *firstPoint = [NSString stringWithFormat:@"%s",(const char *)sqlite3_column_text(stmt, 4)];
            //key
            NSString *lastPoint = [NSString stringWithFormat:@"%s",(const char *)sqlite3_column_text(stmt, 5)];
//            annotRect
            NSString *annotRect = [NSString stringWithFormat:@"%s",(const char *)sqlite3_column_text(stmt, 6)];
            AnnotsModel *c = [AnnotsModel annotsModelWithPageIndex:pageIndex withCurvesData:curvesDa withKey:key withfirstPoint:firstPoint lastPoint:lastPoint withAnnotRect:annotRect];
            [arrM addObject:c];
            
        }
        
    }

    return arrM;
}


@end
