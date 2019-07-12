//
//  MuDocumentViewController.h
//  MuPDFDemo
//
//  Created by navchina on 2017/7/6.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MuDocRef.h"
#import "PagesModel.h"
#include "mupdf/fitz.h"

enum
{
    BARMODE_MAIN,
    BARMODE_SEARCH,
    BARMODE_MORE,
    BARMODE_ANNOTATION,
    BARMODE_HIGHLIGHT,
    BARMODE_UNDERLINE,
    BARMODE_STRIKE,
    BARMODE_INK,
    BARMODE_DELETE
};

@interface MuDocumentViewController : UIViewController<UIScrollViewDelegate,UIAlertViewDelegate>

@property(nonatomic,strong) MuDocRef *docRef;
@property(nonatomic,strong) NSString *filePath;
@property (nonatomic, strong) NSString *uuid;

@property (nonatomic, strong) UIBarButtonItem *inkButton;
@property (nonatomic, strong) UIBarButtonItem *tickButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *deleteButton;
@property (nonatomic, strong) UIBarButtonItem *annotButton;
@property (nonatomic, strong) UIBarButtonItem *switchNightButton;

@property (nonatomic,readonly) UIButton * cornerLeftRotation;
@property (nonatomic,readonly) UIButton * cornerRightRotation;

@property (nonatomic) CGFloat currentRotation;

@property (nonatomic) NSUInteger pageIndex;

@property (nonatomic) NSUInteger pageCount;

@property (nonatomic, strong) UIViewController *parentViewController;


-(instancetype)initWith:(NSString *)filePath
            andDocument:(MuDocRef *)docRef
           andNightMode:(BOOL)nightMode;
//画笔
- (void)inkWithStatus:(BOOL)select;
//旋转
- (void)leftRotation;

- (void)rightRotation;
//刷新页面
- (void)refreshData;
//夜视
- (void)setNight:(BOOL)isNight;
//保存： 标注 + 文档
- (void)save;
//关闭文档
- (void)closeCurrentDocment;

//跳转具体的页码
- (void) gotoPage: (int)number animated: (BOOL)animated;

//获取目录
-(NSArray *)getOutline;
// 根据上一级目录获取下一级
-(NSArray *)getOutlineWithSup:(PagesModel *)pagesM;

// 搜索pdf中是否包含这些字符
-(NSArray *)searchPdfWords:(NSString *)text;
// 从第几页开始搜索 （不开启子线程）
-(NSArray *)searchPdfWords:(NSString *)text fromIndex:(int)index;

//搜索 会开启子线程
-(void)searchPdfWorfs:(NSString *)text fromIndex:(int)index progress:(void(^)(int total,int currentIndex))progress withResult:(void(^)(NSArray *results))result;

// 撤销
-(void)undo;
-(void)redo;

// 签名
-(void)signature;
-(void)reSignature;
-(void)showSignatureWithIndex:(int)Index;

@end
