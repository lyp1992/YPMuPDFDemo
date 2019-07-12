//
//  SiniCustomePDFViewcontroller.h
//  CustomePDFViewController
//
//  Created by yachaocn on 17/2/16.
//  Copyright © 2017年 yachaocn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SiniPDFStyleInstance.h"
#import "SiniPDFCommon.h"

@interface SiniCustomePDFViewcontroller : UIViewController

#pragma mark - 初始化方法
/**
 指定初始化方法
 
 @param styleInstance SiniPDFStyle Instance.
 @return SiniCustomePDF instance.
 */
-(instancetype)initWithStyleInstance:(SiniPDFStyleInstance *)styleInstance;

/**
 右下角工具条
 */
@property(nonatomic,strong) NSArray * cornerToolsItems;

#pragma mark - 属性
/**
 当前文档显示页面的索引
 */
@property(nonatomic) NSUInteger currentPageIndex;

/**
 当前文档的总页数，如果没有设置，返回0
 */
@property(nonatomic,readonly) NSUInteger currentDocumentPageCount;

/**
 获取当前页面的旋转角度
 */
@property(nonatomic,readonly) NSUInteger currentRotation;

/**
 *  签名控制器
 */
@property(nonatomic,strong) UIViewController *siniSignVC;

#pragma mark - 设置
/**
 设置夜市模式

 @param isNight yes:夜晚 No : 白天
 */
- (void)setNightModel:(BOOL)isNight;


#pragma mark - 功能

/**
 更新PDF风格刷新PDF

 @param instanceblock instance
 */
- (void)updateStyleInstanceWithInstance:(void (^)(SiniPDFStyleInstance *instance))instanceblock;

/**
 添加单击PDF事件，可用于EFB相应伸缩页面

 @param tapedEvoke 自定义实现块
 */
- (void)addSingleTapedPDFEvent:(void(^)(CGPoint viewPoint))tapedEvoke;

/**
 关闭当前文档
 */
- (void)closeCurrentDocument;

/**
 清除某页面的Polyline标注: PSPDFAnnotationTypePolyLine.

 @param pageIndex 页码索引
 */
- (void)removePolyLineAnnotationsForPage:(NSUInteger)pageIndex;

/**
 移除当前文档所有的标注
 */
- (void)removeAllCurrentDocumentAnnotations;

/**
 跳转到某页
 */
- (void)scrollToPage:(NSUInteger)page animated:(BOOL)animated;

//------------------------------------------//

// 获取目录
-(void)getOutline;

//搜索
-(void)searchPdfWithText:(NSString *)text;
//搜索
-(void)searchPdfWorfs:(NSString *)text fromIndex:(int)index progress:(void(^)(int total,int currentIndex))progress withResult:(void(^)(NSArray *results))result;

// 撤销
-(void)undo;
-(void)redo;

// 签名
-(void)signature;
// 重签名
-(void)reSignature;
//在具体页面显示签名
-(void)showSignatureWithIndex:(int)index;
@end

#pragma mark - 切换PDF 文档
@interface SiniCustomePDFViewcontroller (SwichPDFFile)

/**
 用 url 切换PDF。
 
 @param fileUrl 文件地址
 */
-(void)displayDocumentWithURL:(NSURL *)fileUrl uid:(NSString *)uid;


@end
#pragma mark 右下角工具条
@interface SiniCustomePDFViewcontroller (CornerTools)

/**
 标注工具条
 */
@property(nonatomic,readonly) UIButton *siniAnnotationItem;

/**
 左旋转
 */
@property(nonatomic,readonly) UIButton *siniLeftRotationItem;

/**
 右旋转
 */
@property(nonatomic,readonly) UIButton *siniRightRotationItem;

/**
 搜索工具
 */
@property(nonatomic,readonly) UIButton *siniMuSearchItem;

/**
 目录
 */
@property(nonatomic,readonly) UIButton *siniMuOutlineItem;
/**
 工具按钮事件回调

 @param complete 回调函数
 */
- (void)addCornerButtonCompleteAction:(void (^)(id target))complete;

@end

