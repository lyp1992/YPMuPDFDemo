//
//  RotatingButtonView.h
//  YPMuPDFDemo
//
//  Created by navchina on 2017/6/27.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RotatingButtonViewDelegate <NSObject>

//旋转代理

-(void)rotatingButtonView:(UIView *)rotatingView clickRotatingButton:(UIButton *)rotatingBtn;

//恢复代理

-(void)rotatingButtonView:(UIView *)rotatingView clickReplyButton:(UIButton *)replyButton;

@end

@interface RotatingButtonView : UIView

@property (nonatomic, weak) id<RotatingButtonViewDelegate>delegate;

@end
