//
//  MuDocumentViewController.m
//  MuPDFDemo
//
//  Created by navchina on 2017/7/6.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "MuDocumentViewController.h"
#import "common.h"
#import "MuDocRef.h"
#import "MuNormalPageView.h"
#import "RotatingButtonView.h"
#import "MuPageView.h"
//#import "AppDelegate.h"
#import "MuTapResult.h"
#import "ToolView.h"
#import "MuOutlineController.h"
#import "MuPdfPageTool.h"
#import "MuWord.h"
#import "PageStringModel.h"

#import "StringEXtension.h"
#import "FmdbTool.h"
#import "AnnotsModel.h"
#import "PreferencesTool.h"
#import "PreferencesModel.h"
#import "DrawViewController.h"
#import "MUPdfImageTool.h"

#import "MLeaksFinder.h"
#import <SiniCustomePDFKit/SiniCustomePDFKit.h>

#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height
#define GAP 20
#define INDICATOR_Y -44-24
#define MIN_SCALE (1.0)
#define MAX_SCALE (5.0)

static NSString *const AlertTitle = @"Save Document?";
// Correct functioning of the app relies on CloseAlertMessage and ShareAlertMessage differing
static NSString *const CloseAlertMessage = @"Changes have been made to the document that will be lost if not saved";
static NSString *const ShareAlertMessage = @"Your changes will not be shared unless the document is first saved";

@interface MuDocumentViewController ()<RotatingButtonViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,assign) BOOL nightMode;
@property (nonatomic, strong)  MuOutlineController *outline;


@property (nonatomic, strong) MuNormalPageView *pageView;

@property (nonatomic, strong) RotatingButtonView *rotatingBtnView;

@property (nonatomic, assign) int clickNumber;
@property (nonatomic, assign) int replyClickNum;

@property (nonatomic, strong) UIScrollView *canvas;

@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign) int current;
@property (nonatomic, strong) UILabel *indicator;
@property (nonatomic, assign) int width; // current screen size
@property (nonatomic, assign) int height;

@property (nonatomic, assign) float scale;

@property (nonatomic, assign) int scroll_animating;


@property (nonatomic, assign) int barmode;
@property (nonatomic, assign) fz_outline *root;
@property (nonatomic, strong) UIView *cview;

@property (nonatomic, strong) NSMutableArray *pageNumArr;
@property (nonatomic, copy) NSString *lastUUid;
@property (nonatomic, assign) int signatureIndex;// 需要签名的index

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, strong) dispatch_queue_t serialQueue;
// 记住画笔状态
@property (nonatomic, assign) BOOL inkStatu;

@end

static void flattenOutline(NSMutableArray *pages, fz_outline *outline, int level)
{
    char indent[8*4+1];
    if (level > 8)
        level = 8;
    memset(indent, ' ', level * 4);
    indent[level * 4] = 0;

    while (outline) {
        
        PagesModel *pagesM = [[PagesModel alloc]init];
        int page = outline->page;
        if (page >= 0 && outline->title)
        {
            NSString *title = @(outline->title);
            pagesM.title = title;
            pagesM.page = page;
        }
        pagesM.downOutline = outline->down;
        pagesM.nextOutline = outline->next;
        pagesM.isSubOutline = outline->down ? YES:NO;
        pagesM.level = 0;
        [pages addObject:pagesM];
        
        outline = outline->next;
    }

}

static char *tmp_path(char *path)
{
    int f;
    char *buf = malloc(strlen(path) + 6 + 1);
    if (!buf)
        return NULL;
    
    strcpy(buf, path);
    strcat(buf, "XXXXXX");
    
    f = mkstemp(buf);
    
    if (f >= 0)
    {
        close(f);
        return buf;
    }
    else
    {
        free(buf);
        return NULL;
    }
}

static void saveDoc(char *current_path, fz_document *doc)
{
    char *tmp;
    pdf_document *idoc = pdf_specifics(ctx, doc);
    pdf_write_options opts = { 0 };
    
    opts.do_incremental = 1;
    
    if (!idoc)
        return;
    
    tmp = tmp_path(current_path);
    if (tmp)
    {
        int written = 0;
        
        fz_var(written);
        fz_try(ctx)
        {
            FILE *fin = fopen(current_path, "rb");
            FILE *fout = fopen(tmp, "wb");
            char buf[256];
            size_t n;
            int err = 1;
            
            if (fin && fout)
            {
                while ((n = fread(buf, 1, sizeof(buf), fin)) > 0)
                    fwrite(buf, 1, n, fout);
                err = (ferror(fin) || ferror(fout));
            }
            
            if (fin)
                fclose(fin);
            if (fout)
                fclose(fout);
            
            if (!err)
            {
                pdf_save_document(ctx, idoc, tmp, &opts);
                written = 1;
            }
        }
        fz_catch(ctx)
        {
            written = 0;
        }
        
        if (written)
        {
            rename(tmp, current_path);
        }
        
        free(tmp);
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

@implementation MuDocumentViewController
enum{
    ResourceCacheMaxSize = 128<<20    /**< use at most 128M for resource cache */
};
+(void)initialize{
    if (self == [MuDocumentViewController class]) {
        queue = dispatch_queue_create("com.artifex.mupdf.queue", NULL);
        //
        ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
        fz_register_document_handlers(ctx);
        screenScale = [UIScreen mainScreen].scale;

    }
}
-(void)loadView{

//    [[NSUserDefaults standardUserDefaults] setObject: self.key forKey: @"OpenDocumentKey"];
//    self.current = (int)[[NSUserDefaults standardUserDefaults]integerForKey:self.key];
    if (self.current < 0 || self.current >= fz_count_pages(ctx, self.docRef.doc))
        self.current = 0;
    self.pageIndex = self.current;
    self.pageCount = fz_count_pages(ctx, self.docRef.doc);
    
    UIView *view = [[UIView alloc] initWithFrame: CGRectZero];
    [view setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [view setAutoresizesSubviews: YES];
    view.backgroundColor = [UIColor whiteColor];
    
    self.canvas = [[UIScrollView alloc] initWithFrame: CGRectMake(0,0,0,0)];
    [self.canvas setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.canvas setPagingEnabled: YES];
    [self.canvas setShowsHorizontalScrollIndicator: NO];
    [self.canvas setShowsVerticalScrollIndicator: NO];
    [self.canvas setDelegate: self];
    
    UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTap:)];
    tapRecog.delegate = self;
    [self.canvas addGestureRecognizer: tapRecog];
   
    // In reflow mode, we need to track pinch gestures on the canvas and pass
    // the scale changes to the subviews.
//    UIPinchGestureRecognizer *pinchRecog = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
//    pinchRecog.delegate = self;
//    [self.canvas addGestureRecognizer:pinchRecog];

   self.scale = 1.0;
   self.scroll_animating = NO;
    
    self.indicator = [[UILabel alloc] initWithFrame: CGRectZero];
    [self.indicator setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
    [self.indicator setText: @"0000 of 9999"];
    self.indicator.font = [UIFont systemFontOfSize:15];
    [self.indicator sizeToFit];
    [self.indicator setCenter: CGPointMake(0, INDICATOR_Y)];
    [self.indicator setTextAlignment: NSTextAlignmentCenter];
    [self.indicator setBackgroundColor: [[UIColor blackColor] colorWithAlphaComponent: 0.5]];
    [self.indicator setTextColor: [UIColor whiteColor]];
    
    [view addSubview: self.canvas];
    [view addSubview: self.indicator];
    
    self.inkButton = [self newResourceBasedButton:@"画笔" withAction:@selector(onInk:)];
    
    self.tickButton = [self newResourceBasedButton:@"确定" withAction:@selector(onTick:)];
    self.cancelButton = [self newResourceBasedButton:@"返回" withAction:@selector(onBack:)];
    self.deleteButton = [self newResourceBasedButton:@"是否删除？" withAction:@selector(onDelete:)];
//    self.annotButton = [self newResourceBasedButton:@"修改" withAction:@selector(onAnnot:)];
    self.annotButton = [self newResourceButtonClick:@"修改" withAction:@selector(onAnnot:)];
    self.switchNightButton = [self newResourceBasedButton:nil];
    
//    self.switchNightButton = [self newResourceBasedButton:@"切换试图" withAction:@selector(onSwitchNight:)];
    
    self.serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    self.operationQueue = [[NSOperationQueue alloc]init];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    
    [self setNavBackgroundColor];
    
    self.inkStatu = NO;
    
    [self setView:view];
    
}
-(UIButton *)cornerLeftRotation{
    return self.rotatingBtnView.rotatingButton;
}
-(UIButton *)cornerRightRotation{
    return self.rotatingBtnView.replyButton;
}
-(void)setUuid:(NSString *)uuid{
    _uuid = uuid;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clickNumber = 1;
    self.rotatingBtnView = [[RotatingButtonView alloc]initWithFrame:CGRectMake(0, 64, 60, 90)];
    self.rotatingBtnView.delegate = self;
//    UIWindow *win = [UIApplication sharedApplication].keyWindow;
//    [win addSubview:self.rotatingBtnView];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:self.inkButton,self.tickButton,self.annotButton, self.switchNightButton,nil]];
    
    //注册通知，点击删除的时候重新加载界面
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadPage) name:reloadThePage object:nil];
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self.indicator setText: [NSString stringWithFormat: @" %d of %d ", self.current+1, fz_count_pages(ctx, self.docRef.doc)]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.rotatingBtnView removeFromSuperview];
    for (UIView *view in [[UIApplication sharedApplication] .keyWindow subviews]) {
        
        if ([view isKindOfClass:[ToolView class]]) {
            
            [view removeFromSuperview];
        }
    }
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGSize size = [self.canvas frame].size;
//    int max_width = fz_max(self.width, size.width);
    
    self.width = size.width;
    self.height = size.height;
    
    [self.canvas setContentInset: UIEdgeInsetsZero];
    [self.canvas setContentSize: CGSizeMake(fz_count_pages(ctx, self.docRef.doc) * self.width, self.height)];
    [self.canvas setContentOffset: CGPointMake(self.current * self.width, 0)];
    
    // use max_width so we don't clamp the content offset too early during animation
//    [self.canvas setContentSize: CGSizeMake(fz_count_pages(ctx, self.docRef.doc) * max_width, self.height)];
//    [self.canvas setContentOffset: CGPointMake(self.current * self.width, 0)];
    
    for (UIView<MuPageView> *view in [self.canvas subviews]) {
        if ([view pageNumber] == self.current) {
            [view setFrame: CGRectMake([view pageNumber] * self.width, 0, self.width, self.height)];
            [view willRotate];
        }
    }
    for (UIView<MuPageView> *view in [self.canvas subviews]) {
        if ([view pageNumber] != self.current) {
            [view setFrame: CGRectMake([view pageNumber] * self.width, 0, self.width, self.height)];
            [view willRotate];
        }
    }
}

- (void) viewDidAppear: (BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollViewDidScroll: self.canvas];
}

- (void) showNavigationBar
{
    if ([[self navigationController] isNavigationBarHidden]) {

        [[self navigationController] setNavigationBarHidden: NO];
        [[self navigationController] setToolbarHidden: NO];
        [self.indicator setHidden: NO];
        
        [UIView beginAnimations: @"MuNavBar" context: NULL];
        
        [[[self navigationController] navigationBar] setAlpha: 1];
        [[[self navigationController] toolbar] setAlpha: 1];
        [self.indicator setAlpha: 1];

        [UIView commitAnimations];
    }
}

-(void)setNavBackgroundColor{
    BOOL isNight = [[NSUserDefaults standardUserDefaults]boolForKey:switchNight];
    if (isNight) {
        self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    }else{
        self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    }
}

- (void) hideNavigationBar
{
    if (![[self navigationController] isNavigationBarHidden]) {
        
        [UIView beginAnimations: @"MuNavBar" context: NULL];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector: @selector(onHideNavigationBarFinished)];
        
        [[[self navigationController] navigationBar] setAlpha: 0];
        [[[self navigationController] toolbar] setAlpha: 0];
        [self.indicator setAlpha: 0];
        
        [UIView commitAnimations];
    }
}

- (void) onHideNavigationBarFinished
{
    [[self navigationController] setNavigationBarHidden: YES];
    [[self navigationController] setToolbarHidden: YES];
    [self.indicator setHidden: YES];
}

-(void)refreshData{

    [self loadPage];
    
    self.pageCount = fz_count_pages(ctx, self.docRef.doc);
}

-(instancetype)initWith:(NSString *)filePath
            andDocument:(MuDocRef *)docRef
           andNightMode:(BOOL)nightMode{
    self = [super init];
    if (!self)
        return nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
#endif
        self.filePath = filePath;
        self.docRef = docRef;
        self.nightMode = nightMode;
        self.view.opaque = YES;
      self.view.backgroundColor = self.nightMode?[UIColor blackColor]:[UIColor whiteColor];
        //注册通知，监听判断旋转，
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    
    return self;
}

- (UIBarButtonItem *) newResourceBasedButton:(NSString *)resource withAction:(SEL)selector
{

    return [[UIBarButtonItem alloc]initWithTitle:resource style:UIBarButtonItemStylePlain target:self action:selector];
}

-(UIBarButtonItem *)newResourceButtonClick:(NSString *)resource withAction:(SEL)selector{

    UIButton *button = [[UIButton alloc]init];
    button.frame = CGRectMake(0, 0, 45, 45);
    [button setTitle:resource forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc]initWithCustomView:button];
}

-(UIBarButtonItem *)newResourceBasedButton:(NSString *)resource{

    UISwitch *switchBtn = [[UISwitch alloc]init];
    switchBtn.on = [[NSUserDefaults standardUserDefaults]boolForKey:switchNight];
    NSLog(@"%d",[[NSUserDefaults standardUserDefaults]boolForKey:switchNight]);
    [switchBtn addTarget:self action:@selector(onSwitchNight:) forControlEvents:UIControlEventValueChanged];
    
    return [[UIBarButtonItem alloc]initWithCustomView:switchBtn];
}

-(void)createPageViewWith:(int)number{
    if (number < 0 || number >= fz_count_pages(ctx, self.docRef.doc)){
        return;
    }
    int found = 0;
    for (UIView<MuPageView> *view in [self.canvas subviews]){
        if ([view pageNumber] == number){
            found = 1;
        }
    }
    if (self.width == 0 && self.height == 0) {
        CGSize size = [self.canvas frame].size;
        self.width = size.width;
        self.height = size.height;
    }
    CGRect rect = CGRectMake(number * self.width, 0, self.width , self.height);
    if (!found) {
//        /***** / // 记住number，当点击其他的pdf时，可以记住之前的绘制结果
        BOOL isDraw = YES;
        if (self.pageNumArr.count != 0) {
            if ([self.pageNumArr containsObject:@(number)]) {
                isDraw = NO;
            }else{
                [self.pageNumArr addObject:@(number)];
            }
        }else{
            [self.pageNumArr addObject:@(number)];
        }
        /*******/
        
        if ([StringEXtension isBlankString:self.lastUUid] || (![StringEXtension isBlankString:self.lastUUid] && ![self.lastUUid isEqualToString:self.uuid])) {
            self.lastUUid = self.uuid;
            NSArray *arrat = [[PreferencesTool shareAnnotDB]selectPreferencesModelListFromDataBaseWithUUid:self.uuid];
            if (arrat.count>0) {
                PreferencesModel *annotsM = arrat[0];
                self.currentRotation = annotsM.rotation;
            }
        }
//        //        查询数据库，取出scale
//        NSArray *arr = [[PreferencesTool shareAnnotDB]selectPreferencesModelListFromDataBaseWithUUid:self.uuid];
//        CGFloat scale = 1;
//        if (arr.count > 0) {
//            PreferencesModel *model = arr[0];
//            scale = model.scale;
//        }
        
        UIView<MuPageView> *view = [[MuNormalPageView alloc] initWithFrame:rect
                                                               andDocument:self.docRef
                                                             andPageNumber:number
                                                              andNightMode:self.nightMode andDegree:self.currentRotation andUUId:self.uuid drawAnnots:isDraw andSignatureIndex:self.signatureIndex scale:1];

        [view setInkStatus:self.inkStatu];
        [self.canvas addSubview:view];
        
    }
}

-(void)statusBarOrientationChange:(NSNotification *)notification{

}

-(void)setContentOffSet{

   
}

-(BOOL)shouldAutorotate{

    return NO;
}

- (void) deleteModeOn
{
//    [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObject:self.deleteButton]];
    self.barmode = BARMODE_DELETE;
}

- (void) inkModeOn
{

    for (UIView<MuPageView> *view in [self.canvas subviews])
    {
        if ([view pageNumber] == self.current)
            [view inkModeOn];
    }
}
- (void) inkModeOff
{
    for (UIView<MuPageView> *view in [self.canvas subviews])
    {
        [view inkModeOff];
    }
}

- (void) showAnnotationMenu
{

    [[self navigationItem] setLeftBarButtonItem:self.cancelButton];
    
    for (UIView<MuPageView> *view in [self.canvas subviews])
    {
        if ([view pageNumber] == self.current)
            [view deselectAnnotation];
    }
    
    self.barmode = BARMODE_ANNOTATION;
}

- (void) onDelete: (id)sender
{
    for (UIView<MuPageView> *view in [self.canvas subviews])
    {
        if ([view pageNumber] == self.current)
            [view deleteSelectedAnnotation];
    }
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:self.inkButton,self.tickButton,self.annotButton, nil]];
    for (UIView<MuPageView> *view in [self.canvas subviews])
    {
        if ([view pageNumber] == self.current)
            [view deselectAnnotation];
    }
    
    self.barmode = BARMODE_ANNOTATION;
    [self showAnnotationMenu];
}

- (void) onBack: (id)sender
{
    pdf_document *idoc = pdf_specifics(ctx, self.docRef.doc);
    if (idoc && pdf_has_unsaved_changes(ctx, idoc))
    {
        UIAlertView *saveAlert = [[UIAlertView alloc]
                                  initWithTitle:AlertTitle message:CloseAlertMessage delegate:self
                                  cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
        [saveAlert show];
     
    }
    else
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

-(void)onAnnot:(UIButton *)sender{

    sender.selected = !sender.selected;

    if (sender.selected) {
        
        [self showAnnotationMenu];
        
    }else{
    
        self.barmode =  BARMODE_MAIN;
    }
    
}

- (void) onInk:(id)sender
{
        self.barmode = BARMODE_INK;
        
        [self inkModeOn];

}
- (void) onTick: (id)sender
{
    for (UIView<MuPageView> *view in [self.canvas subviews])
    {
        if ([view pageNumber] == self.current)
        {
            switch (self.barmode)
            {
                case BARMODE_HIGHLIGHT:
                    [view saveSelectionAsMarkup:PDF_ANNOT_HIGHLIGHT];
                    break;
                    
                case BARMODE_UNDERLINE:
                    [view saveSelectionAsMarkup:PDF_ANNOT_UNDERLINE];
                    break;
                    
                case BARMODE_STRIKE:
                    [view saveSelectionAsMarkup:PDF_ANNOT_STRIKE_OUT];
                    break;
                    
                case BARMODE_INK:
                    [view saveInk];
            }
        }
    }
    
    [self showAnnotationMenu];
}


-(void)onSwitchNight:(UISwitch *)sender{

    //移除之前的页面
    [self deleteCurrentPage];
    
    self.nightMode = sender.isOn;
    
     [[NSUserDefaults standardUserDefaults]setBool:sender.isOn forKey:switchNight];

    [self createPageViewWith:self.current];
    
    if (_isNeedNav) {
        [self setNavBackgroundColor];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([CloseAlertMessage isEqualToString:alertView.message])
    {
        if (buttonIndex == 1)
        
        saveDoc(self.filePath.UTF8String, self.docRef.doc);
        
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

//删除page
-(void)deleteCurrentPage{
    for (UIView<MuPageView> *view in [self.canvas subviews]) {
//                NSLog(@"%@",self.canvas.subviews);
        if ([view pageNumber] == self.current) {
            
            [view removeFromSuperview];
//                        NSLog(@"%@",self.canvas.subviews);
        }
    }
}

#pragma mark --通知
-(void)loadPage{

    [self deleteCurrentPage];
    [self createPageViewWith:self.current];

}

#pragma mark RotatingButtonViewDelegate

-(void)rotatingButtonView:(UIView *)rotatingView clickRotatingButton:(UIButton *)rotatingBtn{
    
    NSArray *arrat = [[PreferencesTool shareAnnotDB]selectPreferencesModelListFromDataBaseWithUUid:self.uuid];
    if (arrat.count>0) {
        PreferencesModel *annotsM = arrat[0];
        self.currentRotation = annotsM.rotation;
    }
    for (UIView<MuPageView> *view in [self.canvas subviews]) {
        if ([view pageNumber] == self.current) {
            if (self.currentRotation==0) {
                self.currentRotation = 3 * M_PI/2;
            }else if (self.currentRotation == 3 * M_PI/2){
                self.currentRotation = M_PI;
            }else if (self.currentRotation == M_PI){
                self.currentRotation =  M_PI/2;
            }else{
                self.currentRotation = 0;
            }
            [view yp_getPDFDirectionWithDegree: self.currentRotation];
        }
    }
    
}

-(void)rotatingButtonView:(UIView *)rotatingView clickReplyButton:(UIButton *)replyButton{
    
    for (UIView<MuPageView> *view in [self.canvas subviews]) {
        if ([view pageNumber] == self.current) {

            if (self.currentRotation == 0) {
                self.currentRotation = M_PI/2;
            }else if (self.currentRotation == M_PI/2){
                self.currentRotation = M_PI;
            }else if (self.currentRotation == M_PI){
                self.currentRotation = 3 * M_PI/2;
            }else{
                self.currentRotation = 0;
            }
            [view yp_getPDFDirectionWithDegree:self.currentRotation];
        }
    }

}

-(void)viewTransformWithClickNumber:(int)clickNum{
    

}

#pragma mark -- scrollviewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    float x = [self.canvas contentOffset].x + self.width * 0.5f;
    self.current = x / self.width;
    self.pageIndex = self.current;
    
    for (UIView<MuPageView> *view in [self.canvas subviews]) {
//        NSLog(@"%@",self.canvas.subviews);
        if ([view pageNumber] <  self.current || [view pageNumber] > self.current  ) {
            
            [view removeFromSuperview];
//            NSLog(@"%@",self.canvas.subviews);
        }
    }

    [self.indicator setText: [NSString stringWithFormat: @" %d of %d ", self.current+1, fz_count_pages(ctx, self.docRef.doc)]];
    [self createPageViewWith:self.current];

}

-(void)dealloc{
    if (self.root) {
        fz_drop_outline(ctx, self.root);
    }
    self.docRef = nil; self.docRef.doc = NULL;
    self.indicator = nil;
    self.filePath = NULL;

    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark --UIGestureDelegate
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{

    return YES;
}
- (void) onTap: (UITapGestureRecognizer*)sender
{
    
    BOOL isHidden = [[NSUserDefaults standardUserDefaults]boolForKey:@"HiddenTool"];
    isHidden = !isHidden;
    SiniCustomePDFViewcontroller *vc = (SiniCustomePDFViewcontroller *)self.parentViewController;
    
    self.rotatingBtnView.hidden = NO;
    
    CGPoint p = [sender locationInView: self.canvas];
    CGPoint ofs = [self.canvas contentOffset];
    float x0 = (self.width - GAP) / 5;
    float x1 = (self.width - GAP) - x0;
    p.x -= ofs.x;
    p.y -= ofs.y;
    __block BOOL tapHandled = NO;
    for (UIView<MuPageView> *view in [self.canvas subviews])
    {
//        [view deselectAnnotation];
        CGPoint pp = [sender locationInView:view];
        if (CGRectContainsPoint(view.bounds, pp))
        {
            MuTapResult *result = [view handleTap:pp];
            __block BOOL hitAnnot = NO;
            __block BOOL hitTool = NO;
            [result switchCaseInternal:^(MuTapResultInternalLink *link) {
//                [self gotoPage:link.pageNumber animated:NO];
                tapHandled = YES;
            } caseExternal:^(MuTapResultExternalLink *link) {
                // Not currently supported
            } caseRemote:^(MuTapResultRemoteLink *link) {
                // Not currently supported
            } caseWidget:^(MuTapResultWidget *widget) {
                tapHandled = YES;
            } caseAnnotation:^(MuTapResultAnnotation *annot) {
                hitAnnot = YES;
            }caseTool:^(MutapResultTool *tool) {
                hitTool = YES;
            }];
            
            switch (self.barmode)
            {
                case BARMODE_ANNOTATION:
                    if (hitAnnot){
                        [self deleteModeOn];
                    }
                    tapHandled = YES;
                    [vc setHiddenTool:isHidden];
                    break;
                    
                case BARMODE_DELETE:
                    if (!hitAnnot)
                        [self showAnnotationMenu];
                    tapHandled = YES;
                    break;
                    
                default:
                {
                  
                    if (hitAnnot)
                    {
                        // Annotation will have been selected, which is wanted
                        // only in annotation-editing mode
//
                    }else if (!hitTool){
                        [view deselectAnnotation];
                      
                        [vc setHiddenTool:isHidden];
                    }else{
                        
                        [vc setHiddenTool:isHidden];
                    }
                    
                }
                    break;
            }
            
            if (tapHandled)
                break;
        }
    }
    if (tapHandled) {
        // Do nothing further
    } else if (p.x < x0) {
//        [self gotoPage: current-1 animated: YES];
    } else if (p.x > x1) {
//        [self gotoPage: current+1 animated: YES];
    } else {
        
        if (self.isNeedNav) {//需要导航栏
            if ([[self navigationController] isNavigationBarHidden])
                [self showNavigationBar];
            else if (self.barmode == BARMODE_MAIN)
                [self hideNavigationBar];
        }
    }

}
//- (void) onPinch:(UIPinchGestureRecognizer*)sender
//{
//    return;
//    if (sender.state == UIGestureRecognizerStateBegan)
//        sender.scale = self.scale;
//
//    if (sender.scale < MIN_SCALE)
//        sender.scale = MIN_SCALE;
//
//    if (sender.scale > MAX_SCALE)
//        sender.scale = MAX_SCALE;
//    if (sender.state == UIGestureRecognizerStateEnded)
//        self.scale = sender.scale;
//
//    for (UIView<MuPageView> *view in [self.canvas subviews])
//    {
//
//        if (view.pageNumber == self.current || sender.state == UIGestureRecognizerStateEnded)
//            [view setScale:sender.scale];
//    }
//
//}

- (void) gotoPage: (int)number animated: (BOOL)animated
{
    if (number < 0)
        number = 0;
    if (number >= fz_count_pages(ctx, self.docRef.doc))
        number = fz_count_pages(ctx, self.docRef.doc) - 1;
    if (self.current == number)
        return;
    if (animated) {

        [UIView beginAnimations: @"MuScroll" context: NULL];
        [UIView setAnimationDuration: 0.4];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector: @selector(onGotoPageFinished)];
        
        for (UIView<MuPageView> *view in self.canvas.subviews)
            [view resetZoomAnimated: NO];
        
        self.canvas.contentOffset = CGPointMake(number * self.width, 0);
        self.indicator.text = [NSString stringWithFormat: @" %d of %d ", number+1, fz_count_pages(ctx, self.docRef.doc)];
        
        [UIView commitAnimations];
    } else {
        for (UIView<MuPageView> *view in self.canvas.subviews)
            [view resetZoomAnimated: NO];
        self.canvas.contentOffset = CGPointMake(number * self.width, 0);
    }
    self.current = number;
}
- (void) onGotoPageFinished
{
    [self scrollViewDidScroll: self.canvas];
}
#pragma mark - 目录
-(NSArray *)getOutline{
    NSArray *outlineArr = [NSArray array];
    fz_outline *outlineRoot = NULL;
    fz_try(ctx)
    outlineRoot = fz_load_outline(ctx, self.docRef.doc);
    fz_catch(ctx)
    outlineRoot = NULL;
    if (outlineRoot)
    {
//      如果有目录
       outlineArr = [self showOutline];
        fz_drop_outline(ctx, outlineRoot);
    }
    return outlineArr;
}

-(NSArray *)showOutline{
    
    NSArray *outlineArr = [NSArray array];
    
    //  rebuild the outline in case the layout has changed
//    fz_outline *root = NULL;
    if (self.root) {
        fz_drop_outline(ctx, self.root);
    }
    self.root = NULL;
    fz_try(ctx)
    self.root = fz_load_outline(ctx, self.docRef.doc);
    fz_catch(ctx)
    self.root = NULL;
    if (self.root)
    {
//        NSMutableArray *titles = [[NSMutableArray alloc] init];
        NSMutableArray *pages = [[NSMutableArray alloc] init];
        flattenOutline(pages, self.root, 0);

        if (pages.count){
            
            outlineArr = pages;//赋值
            
//           self.outline = [[MuOutlineController alloc] initWithTarget: self titles: titles pages: pages];
         
        }
        //  now show it
//        if (self.outline) {
//
//            [self.parentViewController.navigationController pushViewController:self.outline animated:YES];
//        }
//      //  fz_drop_outline(ctx, root);
    }
    return outlineArr;
}

-(NSArray *)getOutlineWithSup:(PagesModel *)pagesM{
    if (pagesM) {
//        MuPdfPageTool *tool = [MuPdfPageTool shareInstance];
        MuPdfPageTool *tool = [[MuPdfPageTool alloc]init];
        return [tool flattenOutlineWith:pagesM];
    }else{
        return [self getOutline];
    }
}

#pragma mark 搜索
-(NSArray *)searchPdfWords:(NSString *)text{
    
   return [self searchPdfWords:text fromIndex:0];
}

// 从第几页开始搜索
-(NSArray *)searchPdfWords:(NSString *)text fromIndex:(int)index{
    //    获取页数
    int pageNumbers = fz_count_pages(ctx, self.docRef.doc);
    NSMutableArray *wordMArr = [NSMutableArray array];
    int count = 0;
    MuPdfPageTool *pageTool = [[MuPdfPageTool alloc]init];
    MuPdfImageTool *imageTool = [[MuPdfImageTool alloc]init];
    for (int i = index; i < pageNumbers; i++) {
        NSArray *words = [pageTool enumerateWords:self.docRef.doc withContext:ctx withPageNumber:i];
        NSString *wordStr = [[NSString alloc]init];
        for (NSArray *lines in words) {
            for (MuWord *word in lines) {
                NSString *str = [NSString stringWithFormat:@"%@ ",word.string];
                wordStr = [wordStr stringByAppendingString:str];
            }
        }
        
        //        搜索是否包含text文字

        BOOL isContainWord = [pageTool SearchForTextContainsWord:wordStr withWord:text];
        
        if (wordStr && ![wordStr isEqualToString:@" "] && wordStr.length > 0 && isContainWord) {

//            UIImage *image = [pageTool loadThumbnailWith:self.docRef.doc withContext:ctx withPageNumber:i];
            UIImage *image = [imageTool loadThumbnailWith:self.docRef.doc withContext:ctx withPageNumber:i];
//            对字符串进行处理
            NSArray *rangeArray = [pageTool rangeOfSubString:text inString:wordStr];
            for (NSValue *rgValue in rangeArray) {
                PageStringModel *stringModel = [[PageStringModel alloc]init];
                stringModel.wordString = wordStr;
                stringModel.pageNumber = i;
                stringModel.pdfImage = image;
                
                NSRange range = [rgValue rangeValue];
                NSAttributedString *arrtibutrstring = [pageTool setAttributeStringFromRange:range inString:wordStr];
                stringModel.attributeString = arrtibutrstring;
                [wordMArr addObject:stringModel];
            }
            count++;
        }
        if (count >= 3) {//大于三张pdf 就返回
            break;
        }
    }
        return wordMArr;
}

-(void)searchPdfWorfs:(NSString *)text fromIndex:(int)index progress:(void (^)(int, int))progress withResult:(void (^)(NSArray *))result{

    [self.operationQueue cancelAllOperations];
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
/* 让当前u页显示搜索结果**/
        
            //             当前页
            char *needle = strdup(text.UTF8String);
            int n = search_page(self.docRef.doc, self.current, needle, NULL);
            if (n) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    for (UIView<MuPageView> *view in self.canvas.subviews){
                        [view showSearchResults:n];
                    }
                    free(needle);
                });
            }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                    for (UIView<MuPageView> *view in self.canvas.subviews){
                        [view clearSearchResults];
                    }
                    free(needle);
                });
            }
      
        
     int pageNumbers = fz_count_pages(ctx, self.docRef.doc);
        
     NSMutableArray *wordMArr = [NSMutableArray array];
     int count = 0;
        
    if (text.length > 0 && index <= pageNumbers) {
            
        
     for (int i = index; i < pageNumbers; i++) {
         if (count >= 3) {
             break;
         }

         MuPdfPageTool *pageTool = [[MuPdfPageTool alloc]init];
         MuPdfImageTool *imageTool = [[MuPdfImageTool alloc]init];
         NSArray *words = [pageTool enumerateWords:self.docRef.doc withContext:ctx withPageNumber:i];

         NSString *wordStr = [[NSString alloc]init];
         for (NSArray *lines in words) {
             for (MuWord *word in lines) {
                 NSString *str = [NSString stringWithFormat:@"%@ ",word.string];
                 wordStr = [wordStr stringByAppendingString:str];
             }
         }
         
         //        搜索是否包含text文字
         BOOL isContainWord = [pageTool SearchForTextContainsWord:wordStr withWord:text];
         
         if (wordStr && ![wordStr isEqualToString:@" "] && wordStr.length > 0 && isContainWord) {
               UIImage *image = [imageTool loadThumbnailWith:self.docRef.doc withContext:ctx withPageNumber:i];
             //            对字符串进行处理
             NSArray *rangeArray = [pageTool rangeOfSubString:text inString:wordStr];
             for (NSValue *rgValue in rangeArray) {
                 PageStringModel *stringModel = [[PageStringModel alloc]init];
                 stringModel.wordString = wordStr;
                 stringModel.pageNumber = i;
                 stringModel.pdfImage = image;
                 
                 NSRange range = [rgValue rangeValue];
                 NSAttributedString *arrtibutrstring = [pageTool setAttributeStringFromRange:range inString:wordStr];
                 stringModel.attributeString = arrtibutrstring;
                 [wordMArr addObject:stringModel];
             }
             count++;
         }
         dispatch_async(dispatch_get_main_queue(), ^{
              progress(pageNumbers,i);
         });
         
     }
        dispatch_async(dispatch_get_main_queue(), ^{
            result(wordMArr);
        });
        }
    }];
    [self.operationQueue addOperation:operation];
}

// 前进
-(void)undo{
    for (UIView<MuPageView> *view in [self.canvas subviews])
    {
        if ([view pageNumber] == self.current)
        {
            [view undo];
        }
    }
}
// 后退
-(void)redo{
    
    for (UIView<MuPageView> *view in [self.canvas subviews])
    {
        if ([view pageNumber] == self.current)
        {
            [view redo];
        }
    }
}

// 签名
-(void)signature{
    
//    弹出签名框
    DrawViewController *drawVC = [[DrawViewController alloc]init];
    [drawVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self.parentViewController presentViewController:drawVC animated:YES completion:nil];
 
    for (UIView<MuPageView> *view in [self.canvas subviews])
    {
        if ([view pageNumber] == self.current)
        {
            [drawVC setSynImagesBlock:^{
                [view signature];
                
//                写入数据库，那本pdf，第几页写了签名
                PreferencesModel *model = [PreferencesModel new];
                model.uuid = self.uuid;
                model.pageNumber = self.current;
                model.rotation = self.currentRotation;
                model.signature = YES;
                [[PreferencesTool shareAnnotDB]insertIntoDataBaseWithModel:model];
                
            }];
        }
    }
}

-(void)reSignature{

//    更新数据库信息
    PreferencesModel *model = [PreferencesModel new];
    model.uuid = self.uuid;
    model.pageNumber = self.current;
    model.rotation = self.currentRotation;
    model.signature = NO;
    [[PreferencesTool shareAnnotDB]insertIntoDataBaseWithModel:model];
    
//    删除本地签名图片
    [[NSFileManager defaultManager]removeItemAtPath:signaturePath error:nil];
    
//    重新刷新页面
    [self loadPage];
    self.signatureIndex = -1;
    
}

-(void)showSignatureWithIndex:(int)Index{
    self.signatureIndex = Index;
    if (self.signatureIndex == self.current) {
        [self loadPage];
    }
}

// 对查询结果进行再分割
#pragma mark - 画笔
- (void)inkWithStatus:(BOOL)select{
    self.inkStatu = select;
    if (select) {
        self.barmode = BARMODE_INK;
        [self inkModeOn];
        self.canvas.scrollEnabled = NO;
    }else{
        //点击删除标注
        [self showAnnotationMenu];
        [self save];
        self.canvas.scrollEnabled = YES;
        [self.pageNumArr removeObject:@(self.current)];
        [self loadPage];
        [self inkModeOff];
    }
 
}
//设置个人喜好是否需要连续
-(void)setContinuouPage:(BOOL)continuous{
    [[NSUserDefaults standardUserDefaults]setBool:continuous forKey:ContinuousPage];
}
#pragma mark - 旋转
//旋转
- (void)rotationToDegress:(NSUInteger)degress{
    
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
//旋转
- (void)leftRotation{
    if ([self.cornerLeftRotation.superview respondsToSelector:@selector(rotatingClick:)]) {
         [self.cornerLeftRotation.superview performSelector:@selector(rotatingClick:) withObject:nil];
    }
   
}
- (void)rightRotation{

    if ([self.cornerRightRotation.superview respondsToSelector:@selector(replyClick:)]) {
        [self.cornerRightRotation.superview performSelector:@selector(replyClick:) withObject:nil];
    }
#pragma clang diagnostic pop
}
#pragma mark - 夜视
//夜视
- (void)setNight:(BOOL)isNight{
    
    [self.pageNumArr removeObject:@(self.current)];
    
    //移除之前的页面
    [self deleteCurrentPage];
    
    self.nightMode = isNight;
    
    [[NSUserDefaults standardUserDefaults]setBool:isNight forKey:switchNight];
    //    NSLog(@"switchNight==%d",[[NSUserDefaults standardUserDefaults]boolForKey:@"switchNight"]);
    self.view.backgroundColor = self.nightMode?[UIColor blackColor]:[UIColor whiteColor];
    [self createPageViewWith:self.current];
    
    if (self.inkStatu) {
        self.barmode = BARMODE_INK;
        [self inkModeOn];
    }
   
    
}
#pragma mark - 保存： 标注 + 文档
- (void)save{
    if (!self.filePath && ![[NSFileManager defaultManager]fileExistsAtPath:self.filePath]) {
        return;
    }
//     saveDoc((char *)self.filePath.UTF8String, self.docRef.doc);
}
#pragma mark - 关闭文档

- (void)closeCurrentDocment{
    [self save];
    self.filePath = nil;
    self.docRef = nil;
    self.docRef.doc = nil;
    if (self.root) {
        fz_drop_outline(ctx, self.root);
    }
}
-(NSMutableArray *)pageNumArr{
    if (!_pageNumArr) {
        _pageNumArr = [NSMutableArray array];
    }
    return _pageNumArr;
}
@end
