//
//  AnnotsModel.h
//  YPMuPDFDemo
//
//  Created by navchina on 2017/8/1.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
@interface AnnotsModel : NSObject

@property (nonatomic, strong) NSString *uuid;

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

//记录当前pdf的旋转方向
@property (nonatomic, assign) CGFloat currentRotation;

+(instancetype)annotsModelWithPageIndex:(NSInteger)pageIndex withUUId:(NSString *)uuid withCurvesData:(NSData *)curvesData withKey:(NSString *)key withfirstPoint:(NSString *)firstPoint lastPoint:(NSString *)lastPoint withAnnotRect:(NSString *)annotRect withRotation:(CGFloat)rotation;

@end
