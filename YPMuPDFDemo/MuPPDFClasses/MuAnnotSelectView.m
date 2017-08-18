//
//  MuAnnotSelectView.m
//  YPMuPDFDemo
//
//  Created by navchina on 2017/7/7.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "MuAnnotSelectView.h"

@interface MuAnnotSelectView ()
{
    ToolView* _toolView;
}
@property(nonatomic, strong) UIButton *deleteButton;
@property(nonatomic, strong) UIView *borderView;

@property (nonatomic, strong) UIView *containView;


@end

@implementation MuAnnotSelectView
{
    MuAnnotation *annot;
    CGSize pageSize;
    UIColor *color;
}

-(UIButton *)deleteButton{

    if (!_deleteButton) {
        
        _deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width - 45, self.bounds.size.height - 45, 45, 45)];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.backgroundColor = [UIColor grayColor];
    }
    return _deleteButton;
}


- (id)initWithAnnot:(MuAnnotation *)_annot pageSize:(CGSize)_pageSize
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
    if (self)
    {
        [self setOpaque:NO];
        annot = _annot;
        pageSize = _pageSize;
        color = [UIColor colorWithRed:0x44/255.0 green:0x44/255.0 blue:1.0 alpha:1.0];

    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    CGSize scale = fitPageToScreen(pageSize, self.bounds.size);
    CGContextRef cref = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(cref, scale.width, scale.height);
    [color set];
    CGContextStrokeRect(cref, annot.rect);
   
}

-(void)deleteClick:(UIButton *)sender{

    if ([_delegate respondsToSelector:@selector(muAnnotSelectView:deleteAnnotSeletViewWithButton:)]) {
        
        [self.delegate muAnnotSelectView:self deleteAnnotSeletViewWithButton:sender];
    }
    
}

@end
