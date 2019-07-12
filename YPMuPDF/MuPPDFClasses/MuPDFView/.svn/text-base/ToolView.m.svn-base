//
//  ToolView.m
//  YPMuPDFDemo
//
//  Created by navchina on 2017/7/19.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "ToolView.h"

@interface ToolView ()

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIButton *copBtn;

@end

@implementation ToolView

- (instancetype)init
{
    self = [super init];
    if (self) {

        [self.imageView addSubview:self.deleteBtn];
        [self.imageView addSubview:self.copBtn];
        [self addSubview:self.imageView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.imageView addSubview:self.deleteBtn];
        [self.imageView addSubview:self.copBtn];
        [self addSubview:self.imageView];
    }
    return self;
}

-(void)layoutSubviews{

    [super layoutSubviews];
    self.imageView.userInteractionEnabled = YES;
    _imageView.frame = CGRectMake(25, 0, 120, 50);
    _deleteBtn.frame = CGRectMake(0, 0, 50, 50);
     _copBtn.frame = CGRectMake(60, 0, 60, 50);
}

-(UIImageView *)imageView{

    if (!_imageView) {
        
        _imageView = [[UIImageView alloc]init];
        _imageView.image = [self strechImage:@"复制框"];
    }
    return _imageView;
}

-(UIButton *)copBtn{

    if (!_copBtn) {
        
        _copBtn = [[UIButton alloc]init];
       
        [_copBtn setTitle:@"复制" forState:UIControlStateNormal];
        [_copBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_copBtn addTarget:self action:@selector(copClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _copBtn;
}

-(UIButton *)deleteBtn{
    
    if (!_deleteBtn) {
        
        _deleteBtn = [[UIButton alloc]init];
        
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        [_deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _deleteBtn;
}

-(void)deleteClick:(UIButton *)sender{

    [self.delegate toolView:self withDeleteAnnot:sender];

}

-(void)copClick:(UIButton *)sender{

    [self.delegate toolView:self withCopyAnnot:sender];

}

-(UIImage *)strechImage:(NSString *)imageStr{

    UIImage *image = [UIImage imageNamed:imageStr];
    // 设置左边端盖宽度
    NSInteger leftCapWidth = image.size.width *0.4;
    NSInteger topCapheight = image.size.height *0.5;
    UIImage *newImage = [image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapheight];
    return newImage;
}


@end
