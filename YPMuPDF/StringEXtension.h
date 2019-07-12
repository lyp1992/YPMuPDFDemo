//
//  StringEXtension.h
//  xydexamAnalysis
//
//  Created by 赖永鹏 on 16/5/27.
//  Copyright © 2016年 Dev..H. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface StringEXtension : NSObject

//判断字符串是否为空
+(BOOL)isBlankString:(NSString *)string;

//判断手机号
+(NSString *)valiMobile:(NSString *)mobile;

//判断字符
+(CGFloat)stringConvertToInt:(NSString*)strtemp;

+(BOOL)JudgeTheillegalCharacter:(NSString *)content;

//格式： http://example.com?param1=value1&param2=value2

+(NSMutableDictionary *)getUrlParameters:(NSString *)urlStr;

+(NSString*) sha1:(NSString *)str;

@end
