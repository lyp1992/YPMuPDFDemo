//
//  ToolView.h
//  YPMuPDFDemo
//
//  Created by navchina on 2017/7/19.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ToolView;
@protocol ToolViewDelegate <NSObject>

-(void)toolView:(ToolView *)view withDeleteAnnot:(UIButton *)sender;

-(void)toolView:(ToolView *)view withCopyAnnot:(UIButton *)sender;

@end
@interface ToolView : UIView

@property (nonatomic, weak) id<ToolViewDelegate>delegate;

@end
