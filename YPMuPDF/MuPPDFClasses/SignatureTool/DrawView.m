//
//  DrawView.m
//  EFBMuPDF
//
//  Created by 赖永鹏 on 2019/7/4.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import "DrawView.h"

@implementation DrawView

-(NSMutableArray*)paths
{
    if (!_paths)
    {
        _paths = [NSMutableArray array];
    }
    return _paths;
}
- (void)drawRect:(CGRect)rect
{
    //1.获取绘制图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //4.添加保存的路径到上下文
    for (MyPath *myPath in self.paths)
    {
        CGContextAddPath(context, myPath.path);
        
        if(myPath.image)
        {
            [myPath.image drawInRect:PHOTO_RECT];
        }
        
        //设置绘图属性
        [myPath.color set];
        CGContextSetLineWidth(context, myPath.lineWidth);
        
        //绘制路径
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    
    //如果是清除或撤销,就不执行当前绘图
    if (!self.isUndo)
    {
        if(self.image)
        {
            [self.image drawInRect:PHOTO_RECT];
        }
        
        //添加当前路径
        CGContextAddPath(context, _path);
        
        //5.设置当前绘图属性
        [self.color set];
        CGContextSetLineWidth(context, self.lineWidth);
        
        //6.绘制路径
        CGContextDrawPath(context, kCGPathStroke);
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isUndo = NO;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"isDefualtColor"])
    {
        //设置默认颜色
        self.color = [UIColor redColor];
    }
    if ([userDefaults boolForKey:@"isDefualtLine"])
    {
        //设置默认线宽
        self.lineWidth = 1.0;
    }
    
    //接收颜色通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(seclectColor:) name:@"ColorNitification" object:nil];
    
    //接收线宽通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectedWidth:) name:@"WidthNitification"  object:nil];
    
    
    //创建路径
    _path = CGPathCreateMutable();
    
    //创建起始点
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGPathMoveToPoint(_path, nil, location.x, location.y);
}

//从通知中获取颜色
-(void)seclectColor:(NSNotification*)notification
{
    self.color = notification.object;
    
    if (self.color == NULL)
    {
        self.color = [UIColor blackColor];
    }
}

//从通知中获取线宽
-(void)selectedWidth:(NSNotification*) notification
{
    NSNumber *number = notification.object;
    self.lineWidth = [number integerValue];
    if (self.lineWidth == 0)
    {
        self.lineWidth = 1.0;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_path)
    {
        //向路径添加新的直线
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        CGPathAddLineToPoint(_path, nil, location.x, location.y);
        
        //让视图刷新
        [self setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_path)
    {
        //保存路径
        MyPath *myPath = [[MyPath alloc]init];
        myPath.path = self.path;
        myPath.color = self.color;
        myPath.lineWidth = self.lineWidth;
        
        if(self.image)
        {
            myPath.image = self.image;
            self.image = nil;
        }
        
        //保存路径
        [self.paths addObject:myPath];
    }
}

-(void)dealloc
{
    //清理保存的路径
    for (MyPath *myPath in self.paths)
    {
        CGPathRelease(myPath.path);
    }
}

@end
