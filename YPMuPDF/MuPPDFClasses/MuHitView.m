//
//  MuHitView.m
//  YPMuPDFDemo
//
//  Created by navchina on 2017/7/6.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "MuHitView.h"
#import "common.h"
@implementation MuHitView
{
    CGSize pageSize;
    int hitCount;
    CGRect hitRects[500];
    int linkPage[500];
    char *linkUrl[500];
    UIColor *color;
}

- (instancetype) initWithSearchResults: (int)n forDocument: (fz_document *)doc
{
    self = [super initWithFrame: CGRectMake(0,0,100,100)];
    if (self) {
        [self setOpaque: NO];
        
//        color = [UIColor colorWithRed: 0x25/255.0 green: 0x72/255.0 blue: 0xAC/255.0 alpha: 0.5];
//        254，197，53
        color = [UIColor colorWithRed:254/255.0 green:219/255.0 blue:55/255.0 alpha:0.5];
        
        pageSize = CGSizeMake(100,100);
        
        for (int i = 0; i < n && i < nelem(hitRects); i++) {
            fz_rect bbox = search_result_bbox(doc, i); // this is thread-safe enough
            hitRects[i].origin.x = bbox.x0;
            hitRects[i].origin.y = bbox.y0;
            hitRects[i].size.width = bbox.x1 - bbox.x0;
            hitRects[i].size.height = bbox.y1 - bbox.y0;
        }
        hitCount = n;
    }
    return self;
}
- (void) drawRect: (CGRect)r
{
    CGSize scale = fitPageToScreen(pageSize, self.bounds.size);
    
    [color set];
    
    for (int i = 0; i < hitCount; i++) {
        CGRect rect = hitRects[i];
        rect.origin.x *= scale.width;
        rect.origin.y *= scale.height;
        rect.size.width *= scale.width;
        rect.size.height *= scale.height;
        UIRectFill(rect);
    }
}
- (void) setPageSize: (CGSize)s
{
    pageSize = s;
    // if page takes a long time to load we may have drawn at the initial (wrong) size
    [self setNeedsDisplay];
}
- (void) dealloc
{
    int i;

    for (i = 0; i < hitCount; i++)
    free(linkUrl[i]);

}
@end
