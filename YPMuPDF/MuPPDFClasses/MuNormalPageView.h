//
//  MuNormalPageView.h
//  MuPDFDemo
//
//  Created by navchina on 2017/7/6.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MuPageViewProtocol.h"
#import "MuPageView.h"
#import "MuLnkView.h"
#import "MuAnnotSelectView.h"


@interface MuNormalPageView : UIScrollView<MuPageViewProtocol,MuPageView,UIScrollViewDelegate,MuAnnotSelectViewDelegate>

-(instancetype)initWithFrame:(CGRect)frame
                 andDocument:(MuDocRef *)docRef
               andPageNumber:(NSInteger)pageNumber
                andNightMode:(BOOL)nightMode andDegree:(CGFloat)degree andUUId:(NSString *)uuid drawAnnots:(BOOL)isDraw
           andSignatureIndex:(int)signaIndex;

@end
