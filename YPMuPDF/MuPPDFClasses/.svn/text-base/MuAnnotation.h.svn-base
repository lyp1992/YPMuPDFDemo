//
//  MuAnnotation.h
//  YPMuPDFDemo
//
//  Created by navchina on 2017/7/6.
//  Copyright © 2017年 LYP. All rights reserved.
//

#include "common.h"
#include "mupdf/pdf.h"
#import <Foundation/Foundation.h>

@interface MuAnnotation : NSObject
-(id) initFromAnnot:(fz_annot *)annot;
@property(readonly) int type;
@property(readonly) CGRect rect;
+(MuAnnotation *) annotFromAnnot:(fz_annot *)annot;
@end
