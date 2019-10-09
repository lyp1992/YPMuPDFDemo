//
//  MuLnkView.m
//  YPMuPDFDemo
//
//  Created by navchina on 2017/7/6.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "MuLnkView.h"
#include "common.h"
#import "MuNormalPageView.h"

@interface MuLnkView ()

@property (nonatomic, strong) NSMutableArray *memoryCursArr;


@end

@implementation MuLnkView
{

    CGSize pageSize;
    NSMutableArray *curves;
    UIColor *color;
    int pageRedoFlags;
    int pageUndoFlags;
}
@synthesize curves;
@synthesize pageUndoFlags;
@synthesize pageRedoFlags;

-(NSMutableArray *)memoryCursArr{
    if (!_memoryCursArr) {
        _memoryCursArr = [NSMutableArray array];
    }
    return _memoryCursArr;
}

-(id)initWithPageSize:(CGSize)_pageSize{

    self = [super initWithFrame:CGRectMake(0, 0, 100, 100)];
    if (self) {
        [self setOpaque:NO];
        pageSize = _pageSize;
        
        BOOL isnightModel = [[NSUserDefaults standardUserDefaults]boolForKey:@"switchNight"];
        
        if (!isnightModel) {//白天
            
            color = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
        }else{
        
            color = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1.0];
        }

        [self.memoryCursArr removeAllObjects];
        pageRedoFlags = 0;
        pageUndoFlags = 0;
        
        curves = [NSMutableArray array];
        UIPanGestureRecognizer *rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDrag:)];
        [self addGestureRecognizer:rec];
    }
    return self;
}

-(void)onDrag:(UIPanGestureRecognizer *)rec
{

    CGSize scale = fitPageToScreen(pageSize, self.bounds.size);
    CGPoint p = [rec locationInView:self];
    p.x /= scale.width;
    p.y /= scale.height;
    
    if (rec.state == UIGestureRecognizerStateBegan)
        [curves addObject:[NSMutableArray array]];
    
    NSMutableArray *curve = [curves lastObject];
    [curve addObject:[NSValue valueWithCGPoint:p]];
    
    pageUndoFlags = (int)curves.count;
    [self setNeedsDisplay];

    if (rec.state == UIGestureRecognizerStateEnded) {
        MuNormalPageView *normalPageV = (MuNormalPageView*)self.superview;
        [normalPageV saveAnnotsModel];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGSize scale = fitPageToScreen(pageSize, self.bounds.size);
    CGContextRef cref = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(cref, scale.width, scale.height);
    
    [color set];
    CGContextSetLineWidth(cref, 5.0);
    
    for (NSArray *curve in curves)
    {
        if (curve.count >= 2)
        {
            CGPoint pt = [[curve objectAtIndex:0] CGPointValue];
            CGContextBeginPath(cref);
            CGContextMoveToPoint(cref, pt.x, pt.y);
            CGPoint lpt = pt;
            
            for (int i = 1; i < curve.count; i++)
            {
                pt = [[curve objectAtIndex:i] CGPointValue];
                CGContextAddQuadCurveToPoint(cref, lpt.x, lpt.y, (pt.x + lpt.x)/2, (pt.y + lpt.y)/2);
                lpt = pt;
            }
            
            CGContextAddLineToPoint(cref, pt.x, pt.y);
            CGContextStrokePath(cref);
        }
    }
    
}

-(void)redo{

    if (self.memoryCursArr.count > 0) {
        
        NSArray *lastArr = self.memoryCursArr.lastObject;
        [curves addObject:lastArr];
        [self.memoryCursArr removeObject:lastArr];
        
        pageUndoFlags = (int)curves.count;
        pageRedoFlags = (int) self.memoryCursArr.count;
        MuNormalPageView *normalPageV = (MuNormalPageView*)self.superview;
        [normalPageV deleteCurrentCurves];
        [normalPageV saveAnnotsModel];
    }
    [self setNeedsDisplay];
}

-(void)undo{

    if (curves.count > 0) {
        NSArray *lastArr = curves.lastObject;
        [self.memoryCursArr addObject:lastArr];
        [curves removeObject:lastArr];
        
        pageUndoFlags = (int)curves.count;
        pageRedoFlags = (int) self.memoryCursArr.count;
        MuNormalPageView *normalPageV = (MuNormalPageView*)self.superview;
        [normalPageV deleteCurrentCurves];
        [normalPageV saveAnnotsModel];
    }
    [self setNeedsDisplay];
}

-(void)curvesRemoveAll{
    [curves removeAllObjects];
}
-(void)clearMemory{
    [self.memoryCursArr removeAllObjects];
}

@end
