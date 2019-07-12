//
//  PageStringModel.h
//  EFBMuPDF
//
//  Created by 赖永鹏 on 2019/6/28.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface PageStringModel : NSObject

@property(nonatomic,copy) NSString *wordString;

@property(nonatomic,assign) int pageNumber;

@property (nonatomic, copy) NSAttributedString *attributeString;

@property (nonatomic, strong) UIImage *pdfImage;

@end

NS_ASSUME_NONNULL_END
