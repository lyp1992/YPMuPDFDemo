//
//  MuHitView.h
//  YPMuPDFDemo
//
//  Created by navchina on 2017/7/6.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "mupdf/fitz.h"

@interface MuHitView : UIView
- (instancetype) initWithSearchResults: (int)n forDocument: (fz_document *)doc;
- (void) setPageSize: (CGSize)s;
@end
