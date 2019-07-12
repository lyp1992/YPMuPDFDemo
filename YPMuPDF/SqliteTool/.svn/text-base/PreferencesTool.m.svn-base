//
//  PreferencesTool.m
//  EFBMuPDF
//
//  Created by 赖永鹏 on 2018/11/14.
//  Copyright © 2018年 赖永鹏. All rights reserved.
//

#import "PreferencesTool.h"
#import "FMDB.h"
#import "PreferencesModel.h"

@interface PreferencesTool ()

@property (nonatomic, strong) FMDatabase *fmdb;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation PreferencesTool

static PreferencesTool *dbTool = nil;
+(PreferencesTool *)shareAnnotDB{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        dbTool = [[PreferencesTool alloc]init];
        [dbTool creatDataBase]; // 创建数据库
        [dbTool createTableInDataBase]; // 创建表
    });
    return dbTool;
}
- (void)creatDataBase {
    self.fmdb = [FMDatabase databaseWithPath:[self dataBasePath]];
}

- (void)createTableInDataBase {
    // 打开数据库
    if (![self.fmdb open]) {
        return;
    }
    
    // 操作数据库 -- 创建表
    [self.fmdb executeUpdate:@"create table if not exists PreferencesModel (id integer primary key autoincrement,uuid text,currentRotation real,pageNumber real,signature real)"];
    
    // 关闭数据库
    [self.fmdb close];
}
-(void)insertIntoDataBaseWithModel:(PreferencesModel *)model{
    if (![dbTool.fmdb open]) {
        return;
    }
    
//    先查model在不在
    BOOL isExit = NO;
      FMResultSet *result = [dbTool.fmdb executeQuery:[NSString stringWithFormat:@"select * from PreferencesModel where uuid = '%@' ",model.uuid]];
        if ([result next]) {
            isExit = YES;
        }
    if (isExit) {
        //更新数据库
        NSString *sql = [NSString stringWithFormat:@"update PreferencesModel SET currentRotation = '%@', pageNumber = '%@' ,signature = '%@'  where uuid ='%@' ",[NSNumber numberWithFloat:model.rotation],[NSNumber numberWithFloat:model.pageNumber],[NSNumber numberWithBool:model.signature],model.uuid];
        BOOL resultB = [dbTool.fmdb executeUpdate:sql];
        NSLog(@"更新：%d",resultB);
    }else{
        [self.fmdb executeUpdate:@"insert into PreferencesModel (uuid,currentRotation,pageNumber,signature) values (?,?,?,?)",model.uuid,[NSNumber numberWithFloat:model.rotation],[NSNumber numberWithInt:model.pageNumber],[NSNumber numberWithBool:model.signature]];
    }
    //关闭数据库
    [dbTool.fmdb close];
}

-(NSMutableArray *)selectPreferencesModelListFromDataBaseWithUUid:(NSString *)uuid{
    if (![self.fmdb open]) {
        return nil;
    }
    FMResultSet *result = [dbTool.fmdb executeQuery:[NSString stringWithFormat:@"select * from PreferencesModel where uuid = '%@' ",uuid]];

    dbTool.dataArray = nil;
    while ([result next]) {
        
        PreferencesModel *model = [PreferencesModel new];
        model.uuid = [result stringForColumn:@"uuid"];
        model.rotation = [[result stringForColumn:@"currentRotation"] floatValue];
        model.pageNumber = [result intForColumn:@"pageNumber"];
        model.signature = [result intForColumn:@"signature"];
        [dbTool.dataArray addObject:model];
    }
    [dbTool.fmdb close];
    return  _dataArray;
}
- (void)deleteUserInfoListFromDataBase {
    if (![dbTool.fmdb open]) {
        return;
    }
    [dbTool.fmdb executeUpdate:@"delete from PreferencesModel"];
    [dbTool.fmdb close];
    return;
}
-(void)updateDataBaseWithUUId:(NSString *)uuid withRotation:(CGFloat)rotation{
    if (![dbTool.fmdb open]) {
        return;
    }
    //更新数据库
    NSString *sql = [NSString stringWithFormat:@"update PreferencesModel SET currentRotation = '%@' where uuid ='%@' ",[NSNumber numberWithFloat:rotation],uuid];
    
    BOOL result = [dbTool.fmdb executeUpdate:sql];
    if (result) {
//        NSLog(@"更新成功");
    }else{
//        NSLog(@"更新失败");
    }
    [dbTool.fmdb close];
}

// 获取数据库文件路径
- (NSString *)dataBasePath {
    //    保存沙盒地址
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *hideDirectory = [NSString stringWithFormat:@"%@%@",cachePath,@"/.hidedir"];
    NSFileManager *fileM = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileM fileExistsAtPath:hideDirectory isDirectory:&isDir]) {
        [fileM createDirectoryAtPath:hideDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //    拼接文件名
    NSString *filePath = [hideDirectory stringByAppendingPathComponent:@"PreferencesModel.db"];
    return filePath;
}

-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
@end
