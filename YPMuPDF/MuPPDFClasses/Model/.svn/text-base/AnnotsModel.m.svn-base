//
//  AnnotsModel.m
//  YPMuPDFDemo
//
//  Created by navchina on 2017/8/1.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "AnnotsModel.h"

@implementation AnnotsModel

+(instancetype)annotsModelWithPageIndex:(NSInteger)pageIndex withUUId:(NSString *)uuid withCurvesData:(NSData *)curvesData withKey:(NSString *)key withfirstPoint:(NSString *)firstPoint lastPoint:(NSString *)lastPoint withAnnotRect:(NSString *)annotRect withRotation:(CGFloat)rotation{
    
    AnnotsModel *model = [[AnnotsModel alloc]init];
    model.curvesData = curvesData;
    model.pageIndex = pageIndex;
    model.key = key;
    model.firstPoint = firstPoint;
    model.lastPoint = lastPoint;
    model.annotRect = annotRect;
    model.uuid = uuid;
    model.currentRotation = rotation;
    return model;
}

@end
