//
//  MuPdfImageTool.m
//  EFBMuPDF
//
//  Created by 赖永鹏 on 2019/7/17.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import "MuPdfImageTool.h"
#include "mupdf/fitz.h"
#import "mupdf/pdf.h"
#import "PagesModel.h"
#import "MuWord.h"
#import "common.h"

@interface MuPdfImageTool ()
@property(nonatomic,assign) fz_page *page;

@property(nonatomic,assign) fz_display_list *page_list;

@property(nonatomic,assign) fz_display_list *annot_list;

@property(nonatomic,assign) fz_pixmap *image_pix;
@property(nonatomic,assign) CGDataProviderRef imageData;
@property(nonatomic,assign) CGSize pageSize;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation MuPdfImageTool

static fz_display_list *create_page_list(fz_document *doc, fz_page *page){
    fz_display_list *list = NULL;
    fz_device *dev = NULL;
    
    fz_var(dev);
    fz_try(ctx){
        list = fz_new_display_list(ctx,NULL);
        dev = fz_new_list_device(ctx, list);
        
        if (page->run_page_contents) {
            
        }
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
            pdf_update_page(ctx, (pdf_page *)page);
        list = fz_new_display_list(ctx, NULL);
        dev = fz_new_list_device(ctx, list);
        for (annot = fz_first_annot(ctx, page); annot; annot = fz_next_annot(ctx, annot))
            fz_run_annot(ctx, annot, dev, &fz_identity, NULL);
        fz_close_device(ctx, dev);
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
    
    screenSize.width *= 1;
    screenSize.height *= 1;
    tileRect.origin.x *= 1;
    tileRect.origin.y *= 1;
    tileRect.size.width *= 1;
    tileRect.size.height *= 1;
    
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
        pix = fz_new_pixmap_with_bbox(ctx, fz_device_rgb(ctx), &bbox, 1);
        fz_clear_pixmap_with_value(ctx, pix, 255);
        
        dev = fz_new_draw_device(ctx, NULL, pix);
        fz_run_display_list(ctx, page_list, dev, &ctm, &rect, NULL);
        fz_run_display_list(ctx, annot_list, dev, &ctm, &rect, NULL);
        
        fz_close_device(ctx, dev);
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

-(UIImage *)loadThumbnailWith:(fz_document *)doc withContext:(fz_context *)ctx2 withPageNumber:(int)pageNumber{
    
//    [self clearMemory];
     UIImage *image;
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL isValid = YES;
        if (pageNumber < 0 || pageNumber >= fz_count_pages(ctx, doc)) {
            isValid = NO;
        };
        if (isValid) {
            
            [self ensureDisplaylistsWith:doc withContext:ctx withPageNumber:pageNumber];
            
            CGRect rect = CGRectMake(0, 0, 70, 90);
            self.image_pix = renderPixmap(doc, self.page_list, self.annot_list, self.pageSize, CGSizeMake(70, 90), rect, 1.0);
            CGDataProviderRelease(self.imageData);
            self.imageData = CreateWrappedPixmap(self.image_pix);
            image = [[NSUserDefaults standardUserDefaults]boolForKey:@"switchNight"]?newInvertImageWithPixmap(self.image_pix, self.imageData):newImageWithPixmap(self.image_pix, self.imageData);
            
        }
//        dispatch_semaphore_signal(semaphore);
//    });
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return image;
    //    return nil;
}
-(void)ensureDisplaylistsWith:(fz_document *)doc withContext:(fz_context *)ctx2 withPageNumber:(int)pageNumber{
    [self ensurePageloadedWith:doc withContext:ctx withPageNumber:pageNumber];
    if (!self.page)
        return;
    
    if (!self.page_list)
        self.page_list = create_page_list(doc, self.page);
    if (!self.annot_list) {
        self.annot_list = create_annot_list(doc, self.page);
    }
}

- (void)ensurePageloadedWith:(fz_document *)doc withContext:(fz_context *)ctx2 withPageNumber:(int)pageNumber{
    if (self.page){
        return;
    }
    fz_try(ctx){
        fz_rect bounds;
        self.page = fz_load_page(ctx, doc, (int)pageNumber);
        if (!self.page) {
            return;
        }
        fz_bound_page(ctx, self.page, &bounds);
        self.pageSize = CGSizeMake(bounds.x1 - bounds.x0 ,bounds.y1 - bounds.y0);
    }
    fz_catch(ctx){
        NSLog(@"%s",ctx->error->message);
        return;
    }
}

-(void)clearMemory{
    //    if (![NSThread isMainThread]) {
    //
    //    } else {
    if (!(_page_list && _annot_list && _page)) {
        return;
    }
    __block fz_display_list *block_page_list = _page_list;
    __block fz_display_list *block_annot_list =_annot_list;
    __block fz_page *block_page = _page;
    //        __block fz_document *block_doc = docRef->doc;
    
    __block CGDataProviderRef block_imageData = _imageData;
    dispatch_async(queue, ^{
        if (block_page_list)
            fz_drop_display_list(ctx, block_page_list);
        if (block_annot_list)
            fz_drop_display_list(ctx, block_annot_list);
        if (block_page)
            fz_drop_page(ctx, block_page);
        block_page = nil;
        if (block_imageData) {
            
            CGDataProviderRelease(block_imageData);
        }
    });
    //    }
}

-(void)dealloc{
    if (![NSThread isMainThread]) {
        
    } else {
        if (!(_page_list && _annot_list && _page)) {
            return;
        }
        __block fz_display_list *block_page_list = _page_list;
        __block fz_display_list *block_annot_list =_annot_list;
        __block fz_page *block_page = _page;
        //        __block fz_document *block_doc = docRef->doc;
        
        __block CGDataProviderRef block_imageData = _imageData;
        dispatch_async(queue, ^{
            if (block_page_list)
                fz_drop_display_list(ctx, block_page_list);
            if (block_annot_list)
                fz_drop_display_list(ctx, block_annot_list);
            if (block_page)
                fz_drop_page(ctx, block_page);
            block_page = nil;
            if (block_imageData) {
                
                CGDataProviderRelease(block_imageData);
            }
        });
    }
}

@end
