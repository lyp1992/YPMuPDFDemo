//
//  MuPdfImageTool.h
//  EFBMuPDF
//
//  Created by 赖永鹏 on 2019/7/17.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <mupdf/fitz.h>
NS_ASSUME_NONNULL_BEGIN

@interface MuPdfImageTool : NSObject

-(UIImage *)loadThumbnailWith:(fz_document *)doc withContext:(fz_context *)ctx2 withPageNumber:(int)pageNumber;

@end

NS_ASSUME_NONNULL_END
