//
//  MuDocumentViewController.h
//  MuPDFDemo
//
//  Created by navchina on 2017/7/6.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "ViewController.h"
#import "MuDocRef.h"
#include "mupdf/fitz.h"
enum
{
    BARMODE_MAIN,
    BARMODE_SEARCH,
    BARMODE_MORE,
    BARMODE_ANNOTATION,
    BARMODE_HIGHLIGHT,
    BARMODE_UNDERLINE,
    BARMODE_STRIKE,
    BARMODE_INK,
    BARMODE_DELETE
};

@interface MuDocumentViewController : UIViewController<UIScrollViewDelegate,UIAlertViewDelegate>

-(instancetype)initWith:(NSString *)filePath
            andDocument:(MuDocRef *)docRef
           andNightMode:(BOOL)nightMode;

- (void)inkWithStatus:(BOOL)select;

@end
