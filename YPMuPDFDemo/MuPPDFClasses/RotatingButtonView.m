//
//  RotatingButtonView.m
//  YPMuPDFDemo
//
//  Created by navchina on 2017/6/27.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "RotatingButtonView.h"

@interface RotatingButtonView ()

@property (nonatomic, strong) UIButton *rotatingButton;

@property (nonatomic, strong) UIButton *replyButton;

@end

@implementation RotatingButtonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.rotatingButton];
        [self addSubview:self.replyButton];
        
    }
    return self;
}


#pragma mark --method

-(void)replyClick:(UIButton *)sender{

    if ([_delegate respondsToSelector:@selector(rotatingButtonView:clickReplyButton:)]) {
        
        [self.delegate rotatingButtonView:self clickReplyButton:sender];
    }
}

-(void)rotatingClick:(UIButton *)sender{

    if ([_delegate respondsToSelector:@selector(rotatingButtonView:clickRotatingButton:)]) {
        
        [self.delegate rotatingButtonView:self clickRotatingButton:sender];
    }
}

#pragma mark -- lazy
//旋转按钮
-(UIButton *)replyButton{

    if (!_replyButton) {
        _replyButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2.0)];
        
        [_replyButton setTitle:@"恢复" forState:UIControlStateNormal];
        [_replyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_replyButton setBackgroundColor:[UIColor grayColor]];
        
        [_replyButton addTarget:self action:@selector(replyClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _replyButton;
}
-(UIButton *)rotatingButton{
    
    if (!_rotatingButton) {
        _rotatingButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2.0, self.frame.size.width, self.frame.size.height/2.0)];
        
        [_rotatingButton setTitle:@"旋转" forState:UIControlStateNormal];
        [_rotatingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rotatingButton setBackgroundColor:[UIColor grayColor]];
        
        [_rotatingButton addTarget:self action:@selector(rotatingClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _rotatingButton;
}

@end
