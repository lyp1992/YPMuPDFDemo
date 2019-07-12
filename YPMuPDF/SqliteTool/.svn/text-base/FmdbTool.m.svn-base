//
//  FmdbTool.m
//  YPMuPDFDemo
//
//  Created by navchina on 2017/8/3.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "FmdbTool.h"
#import "FMDB.h"
#import "AnnotsModel.h"

@interface FmdbTool ()

@property (nonatomic, strong) FMDatabase *fmdb;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation FmdbTool
static FmdbTool *dbTool = nil;
+(FmdbTool *)shareAnnotDB{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        dbTool = [[FmdbTool alloc]init];
        [dbTool creatDataBase]; // 创建数据库
        [dbTool createTableInDataBase]; // 创建表
    });
    return dbTool;
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        self.dataArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataArray;
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
    [self.fmdb executeUpdate:@"create table if not exists annotsModel (id integer primary key autoincrement,uuid text,pageIndex integer,key text,curvesData blob,firstPoint text,lastPoint text,annotRect text,currentRotation real)"];
    
    // 关闭数据库
    [self.fmdb close];
}

-(void)insertIntoDataBaseWithModel:(AnnotsModel *)model{
    if (![dbTool.fmdb open]) {
        return;
    }
    [self.fmdb executeUpdate:@"insert into annotsModel (uuid,pageIndex,curvesData,key,firstPoint,lastPoint,annotRect,currentRotation) values (?,?,?,?,?,?,?,?)",model.uuid,[NSNumber numberWithInteger:model.pageIndex],model.curvesData,model.key,model.firstPoint,model.lastPoint,model.annotRect,[NSNumber numberWithFloat:model.currentRotation]];
    //关闭数据库
    [dbTool.fmdb close];
}

-(NSMutableArray *)selectAnnotsModelListFromDataBaseWithUUid:(NSString *)uuid andPageIndex:(NSInteger)pageIndex{
    if (![self.fmdb open]) {
        return nil;
    }
    FMResultSet *result;
    if (pageIndex < 0) {
        result = [dbTool.fmdb executeQuery:[NSString stringWithFormat:@"select * from annotsModel where uuid = '%@' ",uuid]];
    }else{
        result = [dbTool.fmdb executeQuery:[NSString stringWithFormat:@"select * from annotsModel where uuid = '%@' and pageIndex = '%@' ",uuid,[NSNumber numberWithInteger:pageIndex]]];
    }
    dbTool.dataArray = nil;
    while ([result next]) {
        
        NSInteger pageIndex = [result intForColumn:@"pageIndex"];
        NSData *curvesData = [result dataForColumn:@"curvesData"];
        NSString *key = [result stringForColumn:@"key"];
        NSString *firstPoint = [result stringForColumn:@"firstPoint"];
        NSString *lastPoint = [result stringForColumn:@"lastPoint"];
        NSString *annotRect = [result stringForColumn:@"annotRect"];
        NSString *uuid = [result stringForColumn:@"uuid"];
        CGFloat currentRotation = [[result stringForColumn:@"currentRotation"] floatValue];
        
        AnnotsModel *model = [AnnotsModel annotsModelWithPageIndex:pageIndex withUUId:uuid withCurvesData:curvesData withKey:key withfirstPoint:firstPoint lastPoint:lastPoint withAnnotRect:annotRect withRotation:currentRotation];
        [dbTool.dataArray addObject:model];
    }
    [dbTool.fmdb close];
    return  _dataArray;
}

- (void)deleteUserInfoListFromDataBase {
    if (![dbTool.fmdb open]) {
        return;
    }
    [dbTool.fmdb executeUpdate:@"delete from annotsModel"];
    [dbTool.fmdb close];
    return;
}

-(void)updateDataBaseWithModel:(id)model withCurvesData:(NSData *)data WithAnnotRect:(NSString *)annotRect{
    
    if (![dbTool.fmdb open]) {
        return;
    }
    //更新数据库
    AnnotsModel *annotModel = model;
    
    NSString *sql = [NSString stringWithFormat:@"update annotsModel SET curvesData = '%@',annotRect='%@' where key = '%@' and uuid ='%@' and pageIndex = '%@' ",data,annotRect,annotModel.key,annotModel.uuid,[NSNumber numberWithInteger:annotModel.pageIndex]];
    
    BOOL result = [dbTool.fmdb executeUpdate:sql];
    if (result) {
        //        NSLog(@"更新成功");
    }else{
        //        NSLog(@"更新失败");
    }
    [dbTool.fmdb close];
}

-(void)updateDataBaseWithUUId:(NSString *)uuid withRotation:(CGFloat)rotation{
    if (![dbTool.fmdb open]) {
        return;
    }
    //更新数据库
    NSString *sql = [NSString stringWithFormat:@"update annotsModel SET currentRotation = '%@' where uuid ='%@' ",[NSNumber numberWithFloat:rotation],uuid];
    
    BOOL result = [dbTool.fmdb executeUpdate:sql];
    if (result) {
        //        NSLog(@"更新成功");
    }else{
        //        NSLog(@"更新失败");
    }
    [dbTool.fmdb close];
}

-(void)deleteDataBaseWithAnnotModel:(id)model{
    
    if (![dbTool.fmdb open]) {
        return;
    }
    AnnotsModel *amodel = model;
    NSString *sql = [NSString stringWithFormat:@"delete from AnnotsModel where key='%@' and uuid = '%@'",amodel.key,amodel.uuid];
    BOOL result = [dbTool.fmdb executeUpdate:sql];
    if (result) {
        //        NSLog(@"删除成功");
    }else{
        //        NSLog(@"删除失败");
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
    NSString *filePath = [hideDirectory stringByAppendingPathComponent:@"AnnotsModel.db"];
    return filePath;
}


@end
