//
//  MuLnkView.h
//  YPMuPDFDemo
//
//  Created by navchina on 2017/7/6.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MuLnkView : UIView

@property (readonly) NSArray *curves;

-(id)initWithPageSize:(CGSize)pageSize;

@end
