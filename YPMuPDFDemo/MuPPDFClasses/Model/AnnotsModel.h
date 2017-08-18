//
//  AnnotsModel.h
//  YPMuPDFDemo
//
//  Created by navchina on 2017/8/1.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AnnotsModel : NSObject

//记录当前涂鸦的是第几页
@property (nonatomic, assign) NSInteger pageIndex;

//记录当前涂鸦的point数组
@property (nonatomic, strong) NSData *curvesData;

//primary key
@property (nonatomic, copy) NSString *key;

//刚开始画的第一个点
@property (nonatomic, copy) NSString *firstPoint;
//最后一个画的点
@property (nonatomic, copy) NSString *lastPoint;

@property (nonatomic, copy) NSString *annotRect;

//记录当前copy的时候点击的是第几个
@property (nonatomic, assign) NSInteger copyAnnotIndex;

+(instancetype)annotsModelWithPageIndex:(NSInteger)pageIndex withCurvesData:(NSData *)curvesData withKey:(NSString *)key withfirstPoint:(NSString *)firstPoint lastPoint:(NSString *)lastPoint withAnnotRect:(NSString *)annotRect;

@end
