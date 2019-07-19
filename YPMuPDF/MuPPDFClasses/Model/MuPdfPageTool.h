//
//  MuPdfPageTool.h
//  YPMuPDFDemo
//
//  Created by 赖永鹏 on 2019/6/27.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <mupdf/fitz.h>
NS_ASSUME_NONNULL_BEGIN
@class PagesModel;
@interface MuPdfPageTool : NSObject

//+(MuPdfPageTool *)shareInstance;

//搜索目录
-(NSMutableArray *)flattenOutlineWith:(PagesModel *)pageM;

//获取pdf中的文字(fz_document *doc, fz_page *page)
-(NSMutableArray *)enumerateWords:(fz_document *)doc withContext:(fz_context *)ctx2 withPageNumber:(int)pageNumber;
-(void)enumerateWords:(fz_document*)doc withPageNumber:(int)pageNumber withResult:(void(^)(NSArray *results))result;


// 搜索一段文字是否包含某些字
-(BOOL)SearchForTextContainsWord:(NSString *)text withWord:(NSString *)word;

// 传入字符串和特定的文字，返回attributeString
-(NSAttributedString *)getAttibuteStringWithOldString:(NSString *)oldString withSpecialString:(NSString *)specialStr;

//获取一个字符在字符串中出现的所有位置 返回一个被NSValue包装的NSRange数组
- (NSArray *)rangeOfSubString:(NSString *)subStr inString:(NSString *)string;
- (NSAttributedString *)setAttributeStringFromRange:(NSRange)range inString:(NSString *)inString;



@end

NS_ASSUME_NONNULL_END
