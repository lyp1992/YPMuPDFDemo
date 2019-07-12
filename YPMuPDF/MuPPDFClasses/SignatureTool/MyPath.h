//
//  MyPath.h
//  EFBMuPDF
//
//  Created by 赖永鹏 on 2019/7/4.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define PHOTO_RECT (CGRectMake(0,0,375,330))//绘制照片局域宏定义
@interface MyPath : NSObject

@property (assign,nonatomic)CGMutablePathRef path;   //可变的路径
@property (strong,nonatomic)UIColor *color;  //颜色
@property (assign,nonatomic)NSInteger lineWidth; //线宽
@property (strong,nonatomic)UIImage *image;//图像

@end
