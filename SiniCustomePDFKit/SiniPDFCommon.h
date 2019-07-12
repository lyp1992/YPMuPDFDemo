//
//  SiniPDFCommon.h
//  CustomePDFViewController
//
//  Created by yachaocn on 17/2/20.
//  Copyright © 2017年 yachaocn. All rights reserved.
//

#ifndef SiniPDFCommon_h
#define SiniPDFCommon_h
//color
//黑色
#define SiniPDFNightBackgroundColor [UIColor colorWithRed:29.0/255.0 green:29.0/255.0 blue:30.0/255.0 alpha:1]
//主白色
#define SiniPDFMainWhiteColor [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f]
//EFB 主蓝色
#define SiniMAINVIEWCOLOR [UIColor colorWithRed:59.0/255.0 green:70.0/255.0 blue:86.0/255.0 alpha:1.0]
//标注默认颜色
#define SiniAnnotionLineColor [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:73.0/255.0 alpha:0.5]

#define CornerButtonItemWith        54
#define CornerButtonItemHeight      49

#define IsLandscapeDirection (([UIApplication sharedApplication].statusBarOrientation == (UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight)) ? YES : NO)

#define SiniPDF_DEPRECATED(version, msg) __attribute__((deprecated("Deprecated in SiniPDFKit " #version ". " msg)))


typedef NS_ENUM(NSUInteger, SiniPDFScrollDirection) {
    SiniPDFScrollDirectionHorizontal,
    SiniPDFScrollDirectionVertical
};

typedef NS_ENUM(NSUInteger, SiniPDFPageTransition) {
    SiniPageTransitionScrollPerPage,
    SiniPageTransitionScrollContinuous,
    SiniPageTransitionCurl,
};

typedef NS_ENUM(NSUInteger, SiniPDFPageModel) {
    SiniPDFPageModeSingle,
    SiniPDFPageModeDouble,
    SiniPDFPageModeAutomatic
};

typedef NS_ENUM(NSUInteger, SiniPDFRotationDirection) {
    SiniPDFRotationDirectionTop         = 0,
    SiniPDFRotationDirectionRight       = 90,
    SiniPDFRotationDirectionBottom      = 180,
    SiniPDFRotationDirectionLeft        = 270
};

/**
 Sini PDF  风格

 - SiniPDFViewStyleDay: 日常
 - SiniPDFViewStyleEyecare: 护眼
 - SiniPDFViewStyleDarkBlue: 暗蓝
 - SiniPDFViewStyleCustomeStyle: 自定义
 */
typedef NS_ENUM(NSUInteger, SiniPDFViewStyle) {
    SiniPDFViewStyleDay,
    SiniPDFViewStyleEyecare,
    SiniPDFViewStyleDarkBlue,
    SiniPDFViewStyleCustomeStyle
};

#endif /* SiniPDFCommon_h */
