//
//  MuPdfPageTool.m
//  YPMuPDFDemo
//
//  Created by 赖永鹏 on 2019/6/27.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import "MuPdfPageTool.h"
#include "mupdf/fitz.h"
#import "mupdf/pdf.h"
#import "PagesModel.h"
#import "MuWord.h"
#import "common.h"

@interface MuPdfPageTool ()

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation MuPdfPageTool

static MuPdfPageTool *tool;

//+(MuPdfPageTool *)shareInstance{
//
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        tool = [[self alloc]init];
//    });
//    return tool;
//}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

-(NSMutableArray *)flattenOutlineWith:(PagesModel *)pageM{
    
    NSMutableArray *pages = [[NSMutableArray alloc]init];
    fz_outline *outline = pageM.downOutline;
    while (outline) {
        
        PagesModel *pagesM = [[PagesModel alloc]init];
        int page = outline->page;
        if (page >= 0)
        {
            NSString *title ;
            if (outline->title) {
                NSLog(@"%s",outline->title);
                title = @(outline->title);
            };
            if (title.length == 0 || [title isEqualToString:@" "]) {
                title = pageM.title;
            }
            pagesM.title = title;
            pagesM.page = page;
        }
        pagesM.downOutline = outline->down;
        pagesM.nextOutline = outline->next;
        pagesM.isSubOutline = outline->down ? YES:NO;
        pagesM.level = pageM.level + 1;
        [pages addObject:pagesM];
        
        outline = outline->next;
    }
    return pages;
}
-(void)enumerateWords:(fz_document *)doc withPageNumber:(int)pageNumber withResult:(void (^)(NSArray * results))result{
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        fz_page *page = NULL;
        fz_try(ctx){
            fz_rect bounds;
            page = fz_load_page(ctx, doc, pageNumber);
            fz_bound_page(ctx, page, &bounds);
            
        }
        fz_catch(ctx){
            NSLog(@"%s",ctx->error->message);
            fz_drop_page(ctx, page);
            dispatch_semaphore_signal(self.semaphore);
            result(@[]);
        }
        
        fz_stext_sheet *sheet = NULL;
        fz_stext_page *text = NULL;
        fz_device *dev = NULL;
        NSMutableArray *lns = [NSMutableArray array];
        NSMutableArray *wds;
        MuWord *word;
        
        if (!lns){
            fz_drop_page(ctx, page);
            dispatch_semaphore_signal(self.semaphore);
            result(@[]);
        }
        fz_var(sheet);
        fz_var(text);
        fz_var(dev);
        
        fz_try(ctx)
        {
            fz_rect mediabox;
            int b, l, c;
            
            sheet = fz_new_stext_sheet(ctx);
            text = fz_new_stext_page(ctx, fz_bound_page(ctx, page, &mediabox));
            dev = fz_new_stext_device(ctx, sheet, text, NULL);
            fz_run_page(ctx, page, dev, &fz_identity, NULL);
            fz_close_device(ctx, dev);
            fz_drop_device(ctx, dev);
            dev = NULL;
            
            for (b = 0; b < text->len; b++)
            {
                fz_stext_block *block;
                
                if (text->blocks[b].type != FZ_PAGE_BLOCK_TEXT)
                continue;
                
                block = text->blocks[b].u.text;
                
                for (l = 0; l < block->len; l++)
                {
                    fz_stext_line *line = &block->lines[l];
                    fz_stext_span *span;
                    
                    wds = [NSMutableArray array];
                    if (!wds)
                    fz_throw(ctx, FZ_ERROR_GENERIC, "Failed to create word array");
                    
                    word = [MuWord word];
                    if (!word)
                    fz_throw(ctx, FZ_ERROR_GENERIC, "Failed to create word");
                    
                    for (span = line->first_span; span; span = span->next)
                    {
                        for (c = 0; c < span->len; c++)
                        {
                            fz_stext_char *ch = &span->text[c];
                            fz_rect bbox;
                            CGRect rect;
                            
                            fz_stext_char_bbox(ctx, &bbox, span, c);
                            rect = CGRectMake(bbox.x0, bbox.y0, bbox.x1 - bbox.x0, bbox.y1 - bbox.y0);
                            
                            if (ch->c != ' ')
                            {
                                [word appendChar:ch->c withRect:rect];
                            }
                            else if (word.string.length > 0)
                            {
                                [wds addObject:word];
                                word = [MuWord word];
                                if (!word)
                                fz_throw(ctx, FZ_ERROR_GENERIC, "Failed to create word");
                            }
                        }
                    }
                    
                    if (word.string.length > 0)
                    [wds addObject:word];
                    
                    if (wds.count > 0)
                    [lns addObject:wds];
                }
            }
            fz_close_device(ctx, dev);
        }
        fz_always(ctx)
        {
            fz_drop_stext_page(ctx, text);
            fz_drop_stext_sheet(ctx, sheet);
            fz_drop_device(ctx, dev);
        }
        fz_catch(ctx)
        {
            lns = NULL;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_semaphore_signal(self.semaphore);
            result(lns);
        });
        
    });
    
}
-(NSMutableArray *)enumerateWords:(fz_document *)doc withContext:(fz_context *)ctx2 withPageNumber:(int)pageNumber{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
    __block NSMutableArray *lns = [NSMutableArray array];
    
    dispatch_semaphore_t tmpSeaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        BOOL isValid = YES;
        
        fz_page *page = NULL;
        fz_try(ctx){
            fz_rect bounds;
            page = fz_load_page(ctx, doc, pageNumber);
            fz_bound_page(ctx, page, &bounds);
            
        }
        fz_catch(ctx){
            NSLog(@"%s",ctx->error->message);
            fz_drop_page(ctx, page);
            ;
            isValid = NO;
        }
        
        fz_stext_sheet *sheet = NULL;
        fz_stext_page *text = NULL;
        fz_device *dev = NULL;
        //    NSMutableArray *lns = [NSMutableArray array];
        NSMutableArray *wds;
        MuWord *word;
        
        if (!lns){
            fz_drop_page(ctx, page);
            //        return NULL;
            isValid = NO;
        }
        
        if (isValid) {
            fz_var(sheet);
            fz_var(text);
            fz_var(dev);
            fz_try(ctx)
            {
                fz_rect mediabox;
                int b, l, c;
                
                sheet = fz_new_stext_sheet(ctx);
                text = fz_new_stext_page(ctx, fz_bound_page(ctx, page, &mediabox));
                dev = fz_new_stext_device(ctx, sheet, text, NULL);
                fz_run_page(ctx, page, dev, &fz_identity, NULL);
                fz_close_device(ctx, dev);
                fz_drop_device(ctx, dev);
                dev = NULL;
                
                for (b = 0; b < text->len; b++)
                {
                    fz_stext_block *block;
                    
                    if (text->blocks[b].type != FZ_PAGE_BLOCK_TEXT)
                    continue;
                    
                    block = text->blocks[b].u.text;
                    
                    for (l = 0; l < block->len; l++)
                    {
                        fz_stext_line *line = &block->lines[l];
                        fz_stext_span *span;
                        
                        wds = [NSMutableArray array];
                        if (!wds)
                        fz_throw(ctx, FZ_ERROR_GENERIC, "Failed to create word array");
                        
                        word = [MuWord word];
                        if (!word)
                        fz_throw(ctx, FZ_ERROR_GENERIC, "Failed to create word");
                        
                        for (span = line->first_span; span; span = span->next)
                        {
                            for (c = 0; c < span->len; c++)
                            {
                                fz_stext_char *ch = &span->text[c];
                                fz_rect bbox;
                                CGRect rect;
                                
                                fz_stext_char_bbox(ctx, &bbox, span, c);
                                rect = CGRectMake(bbox.x0, bbox.y0, bbox.x1 - bbox.x0, bbox.y1 - bbox.y0);
                                
                                if (ch->c != ' ')
                                {
                                    [word appendChar:ch->c withRect:rect];
                                }
                                else if (word.string.length > 0)
                                {
                                    [wds addObject:word];
                                    word = [MuWord word];
                                    if (!word)
                                    fz_throw(ctx, FZ_ERROR_GENERIC, "Failed to create word");
                                }
                            }
                        }
                        
                        if (word.string.length > 0)
                        [wds addObject:word];
                        
                        if (wds.count > 0)
                        [lns addObject:wds];
                    }
                }
                fz_close_device(ctx, dev);
            }
            fz_always(ctx)
            {
                fz_drop_stext_page(ctx, text);
                fz_drop_stext_sheet(ctx, sheet);
                fz_drop_device(ctx, dev);
                fz_drop_page(ctx, page);
            }
            fz_catch(ctx)
            {
                lns = NULL;
            }
            dispatch_semaphore_signal(tmpSeaphore);
            dispatch_semaphore_signal(self.semaphore);
            
        }
    });
    
    dispatch_semaphore_wait(tmpSeaphore, DISPATCH_TIME_FOREVER);
    return lns;
}

-(BOOL)SearchForTextContainsWord:(NSString *)text withWord:(NSString *)word{
    
    if ([text containsString:word]) {
        return YES;
    }
    return NO;
}

-(NSAttributedString *)getAttibuteStringWithOldString:(NSString *)oldString withSpecialString:(NSString *)specialStr{
    NSMutableAttributedString* newString = [[NSMutableAttributedString alloc] initWithString:oldString];
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:[NSString stringWithFormat:@"%@",specialStr] options:NSRegularExpressionCaseInsensitive error:nil];
    
    [regex enumerateMatchesInString:oldString options:NSMatchingReportProgress range:NSMakeRange(0, [oldString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [newString addAttribute:(NSString*)NSForegroundColorAttributeName
                          value:(id)[UIColor redColor]
                          range:result.range];
        
    } ];
    
    return newString;
}

-(NSAttributedString *)setAttributeStringFromRange:(NSRange)range inString:(NSString *)inString{
    
    //    截取这个range前后100个字符
    NSString *newString = nil;
    NSUInteger location = 0;
    NSUInteger length = 150;
    NSUInteger newRangeLocation = range.location;
    if (range.location > 15) {
        location = range.location - 15;
        newRangeLocation = 15;
    }else{
        location = 0;
    }
    
    if (inString.length - range.location > 150) {
        length = 150;
    }else{
        length = 15 + inString.length - range.location;
    }
    if (inString.length < length) {
        length = inString.length;
    }
    newString = [inString substringWithRange:NSMakeRange(location, length)];
    range = NSMakeRange(newRangeLocation, range.length);
    
    NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc] initWithString:newString attributes:nil];
    [attributedString setAttributes:@{NSForegroundColorAttributeName:[UIColor yellowColor]} range:range];
     
    return attributedString;
}

//获取一个字符在字符串中出现的所有位置 返回一个被NSValue包装的NSRange数组
- (NSArray *)rangeOfSubString:(NSString *)subStr inString:(NSString *)string {
    if (subStr == nil && [subStr isEqualToString:@""]) {
        return nil;
    }
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSString *string1 = [string stringByAppendingString:subStr];
    NSString *temp;
    for (int i = 0; i < string.length; i ++) {
        temp = [string1 substringWithRange:NSMakeRange(i, subStr.length)];
        if ([temp isEqualToString:subStr]) {
            NSRange range = {i,subStr.length};
            [rangeArray addObject:[NSValue valueWithRange:range]];
        }
    }
    return rangeArray;
}

@end
