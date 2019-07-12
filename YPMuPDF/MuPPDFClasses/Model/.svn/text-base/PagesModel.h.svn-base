//
//  pagesModel.h
//  YPMuPDFDemo
//
//  Created by 赖永鹏 on 2019/6/27.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "mupdf/fitz.h"

NS_ASSUME_NONNULL_BEGIN

@interface PagesModel : NSObject
//{
//    @public
//    fz_outline *downOutline;//outline对象
//    fz_outline *nextOutline;
//}
//标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int level;
//是否有下一页
@property (nonatomic, assign) BOOL isSubOutline;
//第几页
@property (nonatomic, assign) int page;

@property (nonatomic, assign) fz_outline *downOutline;
@property (nonatomic, assign) fz_outline *nextOutline;

@end

NS_ASSUME_NONNULL_END
