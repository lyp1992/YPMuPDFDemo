//
//  MuNormalPageView.m
//  MuPDFDemo
//
//  Created by navchina on 2017/7/6.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "MuNormalPageView.h"
#import "mupdf/pdf.h"
#import "common.h"
#import "MuAnnotation.h"
#import "QBPopupMenu.h"
#import "ToolView.h"
#import "AnnotsModel.h"
#import "FmdbTool.h"

#define STRIKE_HEIGHT (0.375f)
#define UNDERLINE_HEIGHT (0.075f)
#define LINE_THICKNESS (0.07f)
#define INK_THICKNESS (4.0f)

@interface MuNormalPageView()<ToolViewDelegate>{
    
}

@property(nonatomic,assign) fz_page *page;

@property(nonatomic,assign) fz_display_list *page_list;

@property(nonatomic,assign) fz_display_list *annot_list;

@property(nonatomic,assign) fz_pixmap *image_pix;

@property(nonatomic,assign) CGSize pageSize;

@property(nonatomic,assign) CGDataProviderRef imageData;

@property(nonatomic,strong) MuDocRef *docRef;

@property(nonatomic,assign) NSInteger pageNumber;

@property(nonatomic,assign) BOOL nightMode;

@property(nonatomic,strong) UIImageView *imgView;

@property(nonatomic,strong) NSArray *widgetRects;

@property(nonatomic,assign) fz_pixmap *tile_pix;

@property(nonatomic,assign) CGDataProviderRef tileData;

@property(nonatomic,strong) UIImageView *tileView;

@property(nonatomic,assign) CGRect tileFrame;

@property(nonatomic,assign) CGFloat tileScale;

@property(nonatomic, strong) MuLnkView *inkView;

@property(nonatomic, strong) NSArray *annotations;
@property(nonatomic, assign) int selectedAnnotationIndex;

@property(nonatomic, strong) MuAnnotSelectView *annotSelectView;

@property(nonatomic, assign) CGPoint handleTapPoint;
@property(nonatomic, strong) QBPopupMenu *popupMenu;

@property(nonatomic, strong) ToolView *toolView;

//是否是保存到数据库
@property (nonatomic, assign) BOOL isSaveForSql;

//属性记录点击空白区域的时候，是否是复制。
@property (nonatomic, assign) BOOL isCopy;

@property (nonatomic, strong) AnnotsModel *annotModel;

//配置菊花键
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

#pragma -mark 静态方法
static fz_display_list *create_page_list(fz_document *doc, fz_page *page){
    fz_display_list *list = NULL;
    fz_device *dev = NULL;
    
    fz_var(dev);
    fz_try(ctx){
        list = fz_new_display_list(ctx);
        dev = fz_new_list_device(ctx, list);
        fz_run_page_contents(ctx, page, dev, &fz_identity, NULL);
        //        fz_close_device(ctx, dev);
    }
    fz_always(ctx){
        fz_drop_device(ctx, dev);
    }
    fz_catch(ctx){
        return NULL;
    }
    
    return list;
}

static fz_display_list *create_annot_list(fz_document *doc, fz_page *page)
{
    fz_display_list *list = NULL;
    fz_device *dev = NULL;
    
    fz_var(dev);
    fz_try(ctx)
    {
        fz_annot *annot;
        pdf_document *idoc = pdf_specifics(ctx, doc);
        
        if (idoc)
            pdf_update_page(ctx, idoc, (pdf_page *)page);
        list = fz_new_display_list(ctx);
        dev = fz_new_list_device(ctx, list);
        for (annot = fz_first_annot(ctx, page); annot; annot = fz_next_annot(ctx, annot))
            fz_run_annot(ctx, annot, dev, &fz_identity, NULL);
    }
    fz_always(ctx)
    {
        fz_drop_device(ctx, dev);
    }
    fz_catch(ctx)
    {
        return NULL;
    }
    
    return list;
}

static fz_pixmap *renderPixmap(fz_document *doc, fz_display_list *page_list, fz_display_list *annot_list, CGSize pageSize, CGSize screenSize, CGRect tileRect, float zoom)
{
    fz_irect bbox;
    fz_rect rect;
    fz_matrix ctm;
    fz_device *dev = NULL;
    fz_pixmap *pix = NULL;
    CGSize scale;
    
    screenSize.width *= screenScale;
    screenSize.height *= screenScale;
    tileRect.origin.x *= screenScale;
    tileRect.origin.y *= screenScale;
    tileRect.size.width *= screenScale;
    tileRect.size.height *= screenScale;
    
    scale = fitPageToScreen(pageSize, screenSize);
    fz_scale(&ctm, scale.width * zoom, scale.height * zoom);
    
    bbox.x0 = tileRect.origin.x;
    bbox.y0 = tileRect.origin.y;
    bbox.x1 = tileRect.origin.x + tileRect.size.width;
    bbox.y1 = tileRect.origin.y + tileRect.size.height;
    fz_rect_from_irect(&rect, &bbox);
    
    fz_var(dev);
    fz_var(pix);
    fz_try(ctx)
    {
        pix = fz_new_pixmap_with_bbox(ctx, fz_device_rgb(ctx), &bbox);
        fz_clear_pixmap_with_value(ctx, pix, 255);
        
        dev = fz_new_draw_device(ctx, pix);
        fz_run_display_list(ctx, page_list, dev, &ctm, &rect, NULL);
        fz_run_display_list(ctx, annot_list, dev, &ctm, &rect, NULL);
    }
    fz_always(ctx)
    {
        fz_drop_device(ctx, dev);
    }
    fz_catch(ctx)
    {
        fz_drop_pixmap(ctx, pix);
        return NULL;
    }
    
    return pix;
}

static NSArray *enumerateWidgetRects(fz_document *doc, fz_page *page){
    pdf_document *idoc = pdf_specifics(ctx, doc);
    pdf_widget *widget;
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    if (!idoc){
        return nil;
    }
    for (widget = pdf_first_widget(ctx, idoc, (pdf_page *)page); widget; widget = pdf_next_widget(ctx, widget)){
        fz_rect rect;
        pdf_bound_widget(ctx, widget, &rect);
        [arr addObject:[NSValue valueWithCGRect:CGRectMake(rect.x0,rect.y0,rect.x1-rect.x0,rect.y1-rect.y0)]];
    }
    return arr;
}

static NSArray *enumerateAnnotations(fz_document *doc, fz_page *page)
{
    fz_annot *annot;
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    
    for (annot = fz_first_annot(ctx, page); annot; annot = fz_next_annot(ctx, annot))
        [arr addObject:[MuAnnotation annotFromAnnot:annot]];
    
    return arr;
}

static void addInkAnnot(fz_document *doc, fz_page *page, NSArray *curves)
{
    pdf_document *idoc;
    fz_point *pts = NULL;
    int *counts = NULL;
    int total;
    float color[3] = {1.0, 0.0, 0.0};
    
    idoc = pdf_specifics(ctx, doc);
    if (!idoc)
        return;
    
    fz_var(pts);
    fz_var(counts);
    fz_try(ctx)
    {
        int i, j, k, n;
        pdf_annot *annot;
        
        n = (int)curves.count;
        
        counts = fz_malloc_array(ctx, n, sizeof(int));
        total = 0;
        
        for (i = 0; i < n; i++)
        {
            NSArray *curve = [curves objectAtIndex:i];
            counts[i] = (int)curve.count;
            total += (int)curve.count;
        }
        
        pts = fz_malloc_array(ctx, total, sizeof(fz_point));
        
        k = 0;
        for (i = 0; i < n; i++)
        {
            NSArray *curve = [curves objectAtIndex:i];
            int count = counts[i];
            
            for (j = 0; j < count; j++)
            {
                CGPoint pt = [[curve objectAtIndex:j] CGPointValue];
                pts[k].x = pt.x;
                pts[k].y = pt.y;
                k++;
            }
        }
        
        annot = pdf_create_annot(ctx, idoc, (pdf_page *)page, FZ_ANNOT_INK);
        pdf_set_ink_annot_list(ctx, idoc, annot, pts, counts, n, color, INK_THICKNESS);
    }
    fz_always(ctx)
    {
        fz_free(ctx, pts);
        fz_free(ctx, counts);
    }
    fz_catch(ctx)
    {
        printf("Annotation creation failed\n");
    }
}

typedef struct rect_list_s rect_list;

struct rect_list_s
{
    fz_rect rect;
    rect_list *next;
};
static void drop_list(rect_list *list)
{
    while (list)
    {
        rect_list *n = list->next;
        fz_free(ctx, list);
        list = n;
    }
}
static rect_list *updatePage(fz_document *doc, fz_page *page)
{
    rect_list *list = NULL;
    
    fz_var(list);
    fz_try(ctx)
    {
        pdf_document *idoc = pdf_specifics(ctx, doc);
        
        if (idoc)
        {
            fz_annot *annot;
            
            pdf_update_page(ctx, idoc, (pdf_page *)page);
            while ((annot = (fz_annot *)pdf_poll_changed_annot(ctx, idoc, (pdf_page *)page)) != NULL)
            {
                rect_list *node = fz_malloc_struct(ctx, rect_list);
                
                fz_bound_annot(ctx, annot, &node->rect);
                node->next = list;
                list = node;
            }
        }
    }
    fz_catch(ctx)
    {
        drop_list(list);
        list = NULL;
    }
    
    return list;
}

static void deleteAnnotation(fz_document *doc, fz_page *page, int index)
{
    pdf_document *idoc = pdf_specifics(ctx, doc);
    if (!idoc)
        return;
    
    fz_try(ctx)
    {
        int i;
        fz_annot *annot = fz_first_annot(ctx, page);
        for (i = 0; i < index && annot; i++)
            annot = fz_next_annot(ctx, annot);
   
            if (annot)
            pdf_delete_annot(ctx, idoc, (pdf_page *)page, (pdf_annot *)annot);
    }
    fz_catch(ctx)
    {
        printf("Annotation deletion failed\n");
    }
}



//反色
static UIImage *newInvertImageWithPixmap(fz_pixmap *pix, CGDataProviderRef cgdata){
    CGImageRef  imageRef = CreateCGImageWithPixmap(pix, cgdata);
    size_t width  = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t                  bitsPerComponent;
    bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t                  bitsPerPixel;
    bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    size_t                  bytesPerRow;
    bytesPerRow = CGImageGetBytesPerRow(imageRef);
    CGColorSpaceRef         colorSpace;
    colorSpace = CGImageGetColorSpace(imageRef);
    CGBitmapInfo            bitmapInfo;
    bitmapInfo = CGImageGetBitmapInfo(imageRef);
    bool                    shouldInterpolate;
    shouldInterpolate = CGImageGetShouldInterpolate(imageRef);
    CGColorRenderingIntent  intent;
    intent = CGImageGetRenderingIntent(imageRef);
    CGDataProviderRef   dataProvider;
    dataProvider = CGImageGetDataProvider(imageRef);
    CFDataRef   data;
    UInt8*      buffer;
    data = CGDataProviderCopyData(dataProvider);
    buffer = (UInt8*)CFDataGetBytePtr(data);
    NSUInteger  x, y;
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            UInt8*  tmp;
            tmp = buffer + y * bytesPerRow + x * 4;
            UInt8 red,green,blue;
            red = *(tmp + 0);
            green = *(tmp + 1);
            blue = *(tmp + 2);
            
            //            UInt8 brightness;
            *(tmp + 0) = 255 - red;
            *(tmp + 1) = 255 - green;
            *(tmp + 2) = 255 - blue;
            
            
        }
    }
    CFDataRef   effectedData;
    effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
    CGDataProviderRef   effectedDataProvider;
    effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
    CGImageRef  effectedCgImage;
    UIImage*    effectedImage;
    effectedCgImage = CGImageCreate(
                                    width, height,
                                    bitsPerComponent, bitsPerPixel, bytesPerRow,
                                    colorSpace, bitmapInfo, effectedDataProvider,
                                    NULL, shouldInterpolate, intent);
    effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage
                                               scale:screenScale
                                         orientation:UIImageOrientationUp];
    CGImageRelease(effectedCgImage);
    CGImageRelease(imageRef);
    CFRelease(effectedDataProvider);
    CFRelease(effectedData);
    CFRelease(data);
    return effectedImage;
}

//正常色
static UIImage *newImageWithPixmap(fz_pixmap *pix, CGDataProviderRef cgdata){
    CGImageRef cgimage = CreateCGImageWithPixmap(pix, cgdata);
    UIImage *image = [[UIImage alloc] initWithCGImage:cgimage
                                                scale:screenScale
                                          orientation:UIImageOrientationUp];
    CGImageRelease(cgimage);
    return image;
}

static void updatePixmap(fz_document *doc, fz_display_list *page_list, fz_display_list *annot_list, fz_pixmap *pixmap, rect_list *rlist, CGSize pageSize, CGSize screenSize, CGRect tileRect, float zoom)
{
    fz_irect bbox;
    fz_rect rect;
    fz_matrix ctm;
    fz_device *dev = NULL;
    CGSize scale;
    
    screenSize.width *= screenScale;
    screenSize.height *= screenScale;
    tileRect.origin.x *= screenScale;
    tileRect.origin.y *= screenScale;
    tileRect.size.width *= screenScale;
    tileRect.size.height *= screenScale;
    
    scale = fitPageToScreen(pageSize, screenSize);
    fz_scale(&ctm, scale.width * zoom, scale.height * zoom);
    
    bbox.x0 = tileRect.origin.x;
    bbox.y0 = tileRect.origin.y;
    bbox.x1 = tileRect.origin.x + tileRect.size.width;
    bbox.y1 = tileRect.origin.y + tileRect.size.height;
    fz_rect_from_irect(&rect, &bbox);
    
    fz_var(dev);
    fz_try(ctx)
    {
        while (rlist)
        {
            fz_irect abox;
            fz_rect arect = rlist->rect;
            fz_transform_rect(&arect, &ctm);
            fz_intersect_rect(&arect, &rect);
            fz_round_rect(&abox, &arect);
            if (!fz_is_empty_irect(&abox))
            {
                fz_clear_pixmap_rect_with_value(ctx, pixmap, 255, &abox);
                dev = fz_new_draw_device_with_bbox(ctx, pixmap, &abox);
                fz_run_display_list(ctx, page_list, dev, &ctm, &arect, NULL);
                fz_run_display_list(ctx, annot_list, dev, &ctm, &arect, NULL);
                fz_drop_device(ctx, dev);
                dev = NULL;
            }
            rlist = rlist->next;
        }
    }
    fz_always(ctx)
    {
        fz_drop_device(ctx, dev);
    }
    fz_catch(ctx)
    {
    }
}

@implementation MuNormalPageView
#pragma -mark 公开的实例方法
-(instancetype)initWithFrame:(CGRect)frame
                 andDocument:(MuDocRef *)docRef
               andPageNumber:(NSInteger)pageNumber
                andNightMode:(BOOL)nightMode{
    self = [super initWithFrame:frame];
    if (self) {
        //设置基本属性
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 5.0;
        
        [self setShowsVerticalScrollIndicator: NO];
        [self setShowsHorizontalScrollIndicator: NO];
        self.docRef = docRef;
        self.pageNumber = pageNumber;
        self.nightMode = nightMode;
//        self.backgroundColor = [UIColor redColor];
        self.delegate = self;
        
        [self setBouncesZoom: NO];
        [self resetZoomAnimated: NO];
        
        self.selectedAnnotationIndex = -1;
        self.isSaveForSql = NO;
        self.isCopy = NO;
        
        //菊花键
        self.loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.loadingView startAnimating];
        [self addSubview:self.loadingView];
        
        //显示image
        [self loadPage];
        
        //注册通知。改变frame
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(layoutImageView:) name:rotationView object:nil];

        //监听屏幕自动旋转
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.toolView];
        self.toolView.delegate = self;
        
    }
    return self;
}


-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imgView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2);
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2);
    else
        frameToCenter.origin.y = 0;
    
    if (self.loadingView)
        self.loadingView.frame = frameToCenter;
    else
        self.imgView.frame = frameToCenter;
    
    if (self.imgView) {
     
        CGRect frm = [self.imgView frame];
        
        if (self.inkView)
            [self.inkView setFrame:frm];
        
        if (self.annotSelectView)
            [self.annotSelectView setFrame:frm];
        
        if (!self.toolView.hidden) {
            
            [self resizeAnnot];
        }
    }
}

-(void)removeFromSuperview{
    
    [super removeFromSuperview];
}

-(void)setScale:(float)scale{
    
}

-(void)willRotate{
    
    if (self.imgView) {
        
        [self resetZoomAnimated:NO];
        [self resizeImage];
    }
    
}

-(ToolView *)toolView{

    if (!_toolView) {
        
        _toolView = [[ToolView alloc]init];
     
        _toolView.hidden = YES;
    }
    return _toolView;
}
#pragma -mark 私有的实例方法

-(void)layoutImageView:(NSNotification *)notifi{
    
    int i = [notifi.userInfo[@"clickNumber"] intValue];
    //    NSLog(@"i===%d",i);
    self.transform = CGAffineTransformMakeRotation(i * M_PI/2);
    self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    
    [self resetZoomAnimated:NO];
    [self resizeImage];
    if (!self.toolView.hidden) {
        [self resizeAnnot];
    }
}

-(void)statusBarOrientationChange:(NSNotification *)notification{
    if (!self.toolView.hidden) {
        [self resizeAnnot];
    }
}

- (void) loadAnnotations
{
    if (self.pageNumber < 0 || self.pageNumber >= fz_count_pages(ctx, self.docRef.doc))
        return;
    
    NSArray *annots = enumerateAnnotations(self.docRef.doc, self.page);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.annotations = annots;
    });
}

-(void)loadPage{
    if (self.pageNumber < 0 || self.pageNumber >= fz_count_pages(ctx, self.docRef.doc)) {
        return;
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self ensureDisplaylists];
        CGSize scale = fitPageToScreen(self.pageSize, self.bounds.size);
        CGRect rect = CGRectMake(0, 0, self.pageSize.width*scale.width, self.pageSize.height * scale.height);
        self.image_pix = renderPixmap(self.docRef.doc, self.page_list, self.annot_list, self.pageSize, self.bounds.size, rect, 1.0);
        CGDataProviderRelease(self.imageData);
        self.imageData = CreateWrappedPixmap(self.image_pix);
        UIImage *image = self.nightMode?newInvertImageWithPixmap(self.image_pix, self.imageData):newImageWithPixmap(self.image_pix, self.imageData);
        
        [self loadAnnotations];
        //        widgetRects = enumerateWidgetRects(self.docRef.doc, self.page);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"----");
            [self displayImage:image];
            
           // NSDictionary *scaleDic = [NSDictionary dictionaryWithObjectsAndKeys:@(scale),@"scale",self.pageNumber,@"pageNumber", nil];
       
        });
        
    });

  
}

-(void)displayImage:(UIImage*)image{
    
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
    if (!self.imgView) {
        
        self.imgView = [[UIImageView alloc] initWithImage: image];
        self.imgView.opaque = YES;
        
        [self addSubview: self.imgView];
//        self.imgView.backgroundColor = [UIColor redColor];
        
        if (self.inkView)
            [self bringSubviewToFront:self.inkView];
        if (self.annotSelectView)
            [self bringSubviewToFront:self.annotSelectView];
    }else{
        self.imgView.image = image;
    }
    

        [self resizeImage];

}
- (void) resizeImage
{
    if (self.imgView) {
        CGSize imageSize = self.imgView.image.size;
        CGSize scale = fitPageToScreen(imageSize, self.bounds.size);
        //        NSLog(@"imageSize==%@,scale==%@",NSStringFromCGSize(imageSize),NSStringFromCGSize(scale));
        
        if (fabs(scale.width - 1) > 0.1) {
            CGRect frame = [self.imgView frame];
            //            NSLog(@"%@",NSStringFromCGRect(frame));
            frame.size.width = imageSize.width * scale.width;
            frame.size.height = imageSize.height * scale.height;
            [self.imgView setFrame: frame];
            
            printf("resized view; queuing up a reload (%ld)\n", (long)self.pageNumber);
            dispatch_async(queue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGSize scale = fitPageToScreen(self.imgView.image.size, self.bounds.size);
                    if (fabs(scale.width - 1) > 0.01)
                        [self loadPage];
                });
            });
        } else {
            [self.imgView sizeToFit];
            
        }
        
        [self setContentSize: self.imgView.frame.size];
        
        [self layoutIfNeeded];
    }

}

/**
 确保显示列表
 */
-(void)ensureDisplaylists{
    [self ensurePageloaded];
    if (!self.page)
        return;
    
    if (!self.page_list)
        self.page_list = create_page_list(self.docRef.doc, self.page);
    if (!self.annot_list) {
        self.annot_list = create_annot_list(self.docRef.doc, self.page);
    }
}

- (void)ensurePageloaded{
    if (self.page){
        return;
    }
    fz_try(ctx){
        fz_rect bounds;
        self.page = fz_load_page(ctx, self.docRef.doc, (int)self.pageNumber);
        fz_bound_page(ctx, self.page, &bounds);
        self.pageSize = CGSizeMake(bounds.x1 - bounds.x0 ,bounds.y1 - bounds.y0);
    }
    fz_catch(ctx){
        NSLog(@"%s",ctx->error->message);
        return;
    }
}

-(void)loadTile{
    
 

    CGSize screenSize = self.bounds.size;
    self.tileFrame = CGRectMake(self.contentOffset.x, self.contentOffset.y, screenSize.width, screenSize.height);
    self.tileFrame = CGRectIntersection(self.tileFrame, self.imgView.frame);
    self.tileScale = self.zoomScale;
    float scale = self.tileScale;
   
    CGRect frame = self.tileFrame;
    CGRect viewFrame = frame;
//    CGRect viewFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width *scale, frame.size.height *scale);
    
    // Adjust viewFrame to be relative to imageView's origin
    viewFrame.origin.x -= self.imgView.frame.origin.x;
    viewFrame.origin.y -= self.imgView.frame.origin.y;
    
    if (scale < 1.01)
        return;

    dispatch_async(queue, ^{
        __block BOOL isValid;
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            isValid = CGRectEqualToRect(frame, self.tileFrame) && scale == self.tileScale;
        });
        if (!isValid) {
            printf("cancel tile\n");
            return;
        }
        [self ensureDisplaylists];
        printf("render tile\n");
 
        self.tile_pix = renderPixmap(self.docRef.doc, self.page_list, self.annot_list, self.pageSize, screenSize, viewFrame, scale);
        CGDataProviderRelease(self.tileData);
        self.tileData = CreateWrappedPixmap(self.tile_pix);
        UIImage *image = self.nightMode?newInvertImageWithPixmap(self.tile_pix, self.tileData) :newImageWithPixmap(self.tile_pix, self.tileData);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            isValid = CGRectEqualToRect(frame, self.tileFrame) && scale == self.tileScale;
            if (isValid) {
                if (self.tileView) {
                    [self.tileView removeFromSuperview];
                }
                
                self.tileView = [[UIImageView alloc] initWithFrame: frame];
                [self.tileView setImage:image];
                [self addSubview: self.tileView];
             
            }
            if (self.inkView)
                [self bringSubviewToFront:self.inkView];
            if (self.annotSelectView)
                [self bringSubviewToFront:self.annotSelectView];
            
        });
    });
}

-(void)inkModeOn{
    
    self.inkView = [[MuLnkView alloc]initWithPageSize:self.pageSize];
    if (self.imgView) {
        
        [self.inkView setFrame:self.imgView.frame];
    }
    [self addSubview:self.inkView];
    
}
-(void)inkModeOff{
    
    [self.inkView removeFromSuperview];
    
}

-(void)saveInk{
    
    self.isSaveForSql = YES;
    NSArray *curves = self.inkView.curves;
    if (curves.count == 0) {
        return;
    }
    dispatch_async(queue, ^{
        
        addInkAnnot(self.docRef.doc, self.page, curves);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self update];
        });
        
        [self loadAnnotations];
    });
    
    
}

-(void)saveAnnotsModelWithSql{
    
    //保存curves
    //获取时间戳作为key
    AnnotsModel *annotsM = [AnnotsModel new];
    annotsM.pageIndex = self.pageNumber;
    annotsM.key = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] *1000];
    NSLog(@"%@",NSHomeDirectory());
    //    归档放进去
    NSData *arrArchData = [NSKeyedArchiver archivedDataWithRootObject:self.inkView.curves];
    annotsM.curvesData = arrArchData;

    //计算框的大小
    CGPoint point;
    CGRect annotRect;
    CGFloat maxX = 0.0,maxY = 0.0,minX = 0.0,minY = 0.0;
    for (int i = 0; i<self.inkView.curves.count; i++) {
        NSArray *arr = self.inkView.curves[i];
        for (int j = 0; j<arr.count-1; j++) {
            point = [arr[j] CGPointValue];
            maxX = point.x;
            maxY = point.y;
            minX = point.x;
            minY = point.y;
            for (int m = 1; m<arr.count-1; m++) {
                point = [arr[m] CGPointValue];
                if (point.x >maxX) {
                    maxX = point.x;
                }
                if (point.y >maxY) {
                    maxY = point.y;
                }
                if (point.x<minX) {
                    minX = point.x;
                }
                if (point.y<minY) {
                    minY = point.y;
                }
            }
        }
    }
    annotRect = CGRectMake(minX, minY, maxX - minX, maxY -minY);
    annotsM.annotRect = [NSString stringWithFormat:@"%@",NSStringFromCGRect(annotRect)];
    annotsM.firstPoint = [NSString stringWithFormat:@"%@",self.inkView.curves.firstObject];
    annotsM.lastPoint = [NSString stringWithFormat:@"%@",self.inkView.curves.lastObject];
    
    [[FmdbTool shareAnnotDB]insertIntoDataBaseWithModel:annotsM];

    self.isSaveForSql = NO;
    self.isCopy = NO;
}

-(void) selectAnnotation:(int)i
{
    self.selectedAnnotationIndex = i;
    [self.annotSelectView removeFromSuperview];
    
    self.annotSelectView = [[MuAnnotSelectView alloc] initWithAnnot:[self.annotations objectAtIndex:i] pageSize:self.pageSize];
    self.annotSelectView.delegate = self;
    [self addSubview:self.annotSelectView];
    
    //添加工具几条
    [self resizeAnnot];
}


-(void) deselectAnnotation
{
    self.selectedAnnotationIndex = -1;
    [self.annotSelectView removeFromSuperview];
    self.toolView.hidden = YES;
//    self.isCopy = NO;
}

-(void) deleteSelectedAnnotation
{
    int index = self.selectedAnnotationIndex;
    if (index >= 0)
    {
        dispatch_async(queue, ^{
            deleteAnnotation(self.docRef.doc, self.page, index);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self update];
            });
            [self loadAnnotations];
        });
    }
    [self deselectAnnotation];
}

//绘制新区域
-(void)drawAnnotsWithPoint{

    NSArray *curves = [NSKeyedUnarchiver unarchiveObjectWithData:self.annotModel.curvesData];
    if (curves.count == 0) {
        return;
    }
    //转换坐标
    CGPoint ipt = [self convertPoint:self.handleTapPoint toView:self.imgView];
    CGSize scale = fitPageToScreen(self.pageSize, self.imgView.bounds.size);
    ipt.x /= scale.width;
    ipt.y /= scale.height;
    CGRect annotRect = CGRectFromString(self.annotModel.annotRect);
    CGPoint annotPoint = CGPointMake(annotRect.origin.x + annotRect.size.width/2, annotRect.origin.y + annotRect.size.height/2);
    //计算偏移值
    CGFloat widthX = ipt.x - annotPoint.x;
    CGFloat heightY = ipt.y - annotPoint.y;
    //计算所有的偏移坐标
    NSMutableArray *curvesNew = [NSMutableArray array];
    for (int i = 0; i<curves.count; i++) {
        NSArray *pointArr = curves[i];
        NSMutableArray *pointM = [NSMutableArray array];
        for (int j = 0; j<pointArr.count; j++) {
            CGPoint point = [pointArr[j] CGPointValue];
            point.x = point.x + widthX;
            point.y = point.y + heightY;
            [pointM addObject:[NSValue valueWithCGPoint:point]];
        }
        [curvesNew addObject:pointM];
    }
    
    NSData *curvesData = [NSKeyedArchiver archivedDataWithRootObject:curvesNew];
    CGRect annotRectNew = CGRectMake(annotRect.origin.x + widthX, annotRect.origin.y + heightY, annotRect.size.width, annotRect.size.height);
    NSString *annotRectStr = [NSString stringWithFormat:@"%@",NSStringFromCGRect(annotRectNew)];
    
    //按照新坐标的绘制
    dispatch_async(queue, ^{
       
        int index = (int)self.annotModel.copyAnnotIndex;
        if (index >= 0) {
            //删除原来的
            deleteAnnotation(self.docRef.doc, self.page, index);
            //更新数据库中这一条数据的值curvesData，和annotRect
//            [[FmdbTool shareAnnotDB]updateDataBaseWithModel:self.annotModel withCurvesData:curvesData WithAnnotRect:annotRectStr];
            [[FmdbTool shareAnnotDB]deleteDataBaseWithAnnotModel:self.annotModel];//删除旧的
            
            AnnotsModel *anoM = [AnnotsModel new];
            anoM.pageIndex = self.annotModel.pageIndex;
            anoM.annotRect = annotRectStr;
            anoM.curvesData = curvesData;
            anoM.key = self.annotModel.key;
            anoM.firstPoint = self.annotModel.firstPoint;
            anoM.lastPoint = self.annotModel.lastPoint;
            [[FmdbTool shareAnnotDB]insertIntoDataBaseWithModel:anoM];//创建新的
        }
        addInkAnnot(self.docRef.doc, self.page, curvesNew);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self update];
        });
        
        [self loadAnnotations];
    });
     [self deselectAnnotation];
}

#pragma -mark UIScrollViewDelegate的实现
- (UIView*) viewForZoomingInScrollView: (UIScrollView*)scrollView
{
    return self.imgView;
}
- (void) scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    
        [self loadTile];
}
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
        [self loadTile];
}
//滚动停止
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self loadTile];

    if (!self.toolView.hidden) {
        [self resizeAnnot];
    }

}
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
        if (!decelerate)
            [self loadTile];
        if (!self.toolView.hidden) {
            [self resizeAnnot];
        }
}

- (void) scrollViewWillBeginZooming: (UIScrollView*)scrollView withView: (UIView*)view
{
    // discard tile and any pending tile jobs
    self.tileFrame = CGRectZero;
    self.tileScale = 1;
    if (self.tileView) {
        [self.tileView removeFromSuperview];
    }
    if (!self.toolView.hidden) {
        [self resizeAnnot];
    }
    
}

- (void) scrollViewDidEndZooming: (UIScrollView*)scrollView withView: (UIView*)view atScale: (CGFloat)scale
{
    
    [self loadTile];
    //记录当前scale
    NSDictionary *scaleDic = [NSDictionary dictionaryWithObjectsAndKeys:@(scale),@"scale",@(self.pageNumber),@"pageNumber", nil];
    [[NSUserDefaults standardUserDefaults]setObject:scaleDic forKey:@"scale"];
  
}

- (void) scrollViewDidZoom: (UIScrollView*)scrollView
{
    if (self.imgView)
    {
        if (!self.toolView.hidden) {
            
            [self resizeAnnot];
        }
        
        CGRect frm = [self.imgView frame];
        
        if (self.inkView)
            [self.inkView setFrame:frm];
        
        if (self.annotSelectView)

            [self.annotSelectView setFrame:frm];
    }
    
}

-(void)resetZoomAnimated:(BOOL)animated{
    
    self.tileFrame = CGRectZero;
    self.tileScale = 1;
    if (self.tileView) {
        
        [self.tileView removeFromSuperview];
        
    }
    [self setMinimumZoomScale:1];
    [self setMaximumZoomScale:5];
    [self setZoomScale:1 animated:animated];
    
}

- (void) updatePageAndTileWithTileFrame:(CGRect)tframe tileScale:(float)tscale viewFrame:(CGRect)vframe
{
    rect_list *rlist = updatePage(self.docRef.doc, self.page);
    fz_drop_display_list(ctx, self.annot_list);
    self.annot_list = create_annot_list(self.docRef.doc, self.page);
    if (self.tile_pix)
    {
        updatePixmap(self.docRef.doc, self.page_list, self.annot_list, self.tile_pix, rlist, self.pageSize, self.bounds.size, vframe, tscale);
        //        UIImage *timage = self.nightMode ? newImageWithPixmap(self.tile_pix, self.tileData):newInvertImageWithPixmap(self.tile_pix, self.tileData);
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL isValid = CGRectEqualToRect(tframe, self.tileFrame) && tscale == self.tileScale;
            if (isValid)
                //                [self.tileView setImage:timage];
                
                //发送重新加载界面的通知
                [[NSNotificationCenter defaultCenter]postNotificationName:reloadThePage object:nil];
            if (self.isSaveForSql) {
                //保存到数据库
                [self saveAnnotsModelWithSql];
            }
        });
    }
    CGSize fscale = fitPageToScreen(self.pageSize, self.bounds.size);
    CGRect rect = (CGRect){{0.0, 0.0},{self.pageSize.width * fscale.width, self.pageSize.height * fscale.height}};
    updatePixmap(self.docRef.doc, self.page_list, self.annot_list, self.image_pix, rlist, self.pageSize, self.bounds.size, rect, 1.0);
    drop_list(rlist);
    //    UIImage *image = self.nightMode ? newImageWithPixmap(self.image_pix, self.imageData):newInvertImageWithPixmap(self.image_pix, self.imageData);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //发送重新加载界面的通知
        [[NSNotificationCenter defaultCenter]postNotificationName:reloadThePage object:nil];
        if (self.isSaveForSql) {
            //保存到数据库
            [self saveAnnotsModelWithSql];
        }
    });
}

- (void) update
{
    CGRect tframe = self.tileFrame;
    float tscale = self.tileScale;
    CGRect vframe = tframe;
    vframe.origin.x -= self.imgView.frame.origin.x;
    vframe.origin.y -= self.imgView.frame.origin.y;
    
    dispatch_async(queue, ^{
        [self updatePageAndTileWithTileFrame:tframe tileScale:tscale viewFrame:vframe];
    });
}

- (MuTapResult *) handleTap:(CGPoint)pt
{
    //记录当前点击的annot
    self.handleTapPoint = pt;
    
    CGPoint ipt = [self convertPoint:pt toView:self.imgView];
    CGSize scale = fitPageToScreen(self.pageSize, self.imgView.bounds.size);
    int i;
    
    ipt.x /= scale.width;
    ipt.y /= scale.height;
    
    for (i = 0; i < self.annotations.count; i++)
    {
        MuAnnotation *annot = [self.annotations objectAtIndex:i];
        //选中已经画好
        if (annot.type != FZ_ANNOT_WIDGET && CGRectContainsPoint(annot.rect, ipt))
        {
            [self selectAnnotation:i];
            return [[MuTapResultAnnotation alloc] initWithAnnotation:annot];
        }else{//选中空白区域
            if (self.isCopy) {
                //绘制新区域
                
                NSLog(@"点击了空白位置selectedAnnotationIndex==%d",self.selectedAnnotationIndex);
                [self drawAnnotsWithPoint];
                return nil;
            }
        }
    }
    
    [self deselectAnnotation];
    
    return nil;
}

//覆盖annot
-(void)resizeAnnot{

    self.toolView.hidden = NO;
    CGPoint ipt = [self convertPoint:self.handleTapPoint toView:self.imgView];
    CGSize scale = fitPageToScreen(self.pageSize, self.imgView.bounds.size);
    ipt.x /= scale.width;
    ipt.y /= scale.height;
    
    for ( int i = 0; i < self.annotations.count; i++)
    {
        MuAnnotation *annot = [self.annotations objectAtIndex:i];
        if (annot.type != FZ_ANNOT_WIDGET)
        {
            
            CGRect rect = [self.imgView convertRect:CGRectMake(annot.rect.origin.x * scale.width, annot.rect.origin.y*scale.height, annot.rect.size.width*scale.width, annot.rect.size.height*scale.height) toView:[UIApplication sharedApplication].keyWindow];
     
            //转换坐标
            [self.toolView setFrame:CGRectMake(rect.origin.x - 50, rect.origin.y - 50, rect.size.width + 50, rect.size.height + 50)];
        }
    }
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.toolView removeFromSuperview];
    
    if (![NSThread isMainThread]) {
        
    } else {
        __block fz_display_list *block_page_list = _page_list;
        __block fz_display_list *block_annot_list =_annot_list;
        __block fz_page *block_page = _page;
        //		__block fz_document *block_doc = docRef->doc;
        __block CGDataProviderRef block_tileData = _tileData;
        __block CGDataProviderRef block_imageData = _imageData;
        dispatch_async(queue, ^{
            if (block_page_list)
                fz_drop_display_list(ctx, block_page_list);
            if (block_annot_list)
                fz_drop_display_list(ctx, block_annot_list);
            if (block_page)
                fz_drop_page(ctx, block_page);
            block_page = nil;
            CGDataProviderRelease(block_tileData);
            CGDataProviderRelease(block_imageData);
        });
    }
}

#pragma mark --MuAnnotSelectViewDelegate
-(void)muAnnotSelectView:(MuAnnotSelectView *)view deleteAnnotSeletViewWithButton:(UIButton *)sender{
    
    [self deleteSelectedAnnotation];
    
    [self setNeedsDisplay];
}

#pragma mark -- ToolViewDelegate
-(void)toolView:(ToolView *)view withDeleteAnnot:(UIButton *)sender{
  
    [self deleteSelectedAnnotation];
    //删除数据库中的这一条
    [self searchAnnotModelFromDataBase:YES];
    
    [self setNeedsDisplay];
    
}

-(void)toolView:(ToolView *)view withCopyAnnot:(UIButton *)sender{
    
    NSLog(@"点击了空白位置selectedAnnotationIndex==%d",self.selectedAnnotationIndex);
    //mupdf删除的时候是点击的是哪个利用containPoint来区分。
    [self searchAnnotModelFromDataBase:NO];
}

-(void)searchAnnotModelFromDataBase:(BOOL)isDelete{

    //读取数据库
    NSArray *arr = [[FmdbTool shareAnnotDB]selectAnnotsModelListFromDataBase];
    if (arr.count==0) {
        NSLog(@"出错了");
    }
    for (AnnotsModel *annotsModel in arr) {
        
        //首先在数据库中找是否是这一页
        if (annotsModel.pageIndex == self.pageNumber) {
            //取出annotRect
            CGPoint ipt = [self convertPoint:self.handleTapPoint toView:self.imgView];
            CGSize scale = fitPageToScreen(self.pageSize, self.imgView.bounds.size);
            ipt.x /= scale.width;
            ipt.y /= scale.height;
            CGRect annotRect = CGRectFromString(annotsModel.annotRect);
            
            
            if (CGRectContainsPoint(annotRect, ipt)) {
                //
                NSLog(@"成功找到了");
                if (isDelete) {
                    [[FmdbTool shareAnnotDB]deleteDataBaseWithAnnotModel:annotsModel];
                }else{
                    self.isCopy = YES;
                    annotsModel.copyAnnotIndex = self.selectedAnnotationIndex;
                    self.annotModel = annotsModel;
                    NSLog(@"%@",self.annotModel.key);
                }
            }else{
                
                NSLog(@"数据库中没有");
            }
        }
    }
}

@end
