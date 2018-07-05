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
#import "AppDelegate.h"
#import "MuTapResult.h"
#import "ToolView.h"

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

@property(nonatomic,strong) MuDocRef *docRef;

@property(nonatomic,strong) NSString *filePath;

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
@property (nonatomic, strong) UIBarButtonItem *	inkButton ;
@property (nonatomic, strong) UIBarButtonItem *tickButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *deleteButton;
@property (nonatomic, strong) UIBarButtonItem *annotButton;
@property (nonatomic, strong) UIBarButtonItem *switchNightButton;

@property (nonatomic, assign) int barmode;


@end

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

@implementation MuDocumentViewController

-(void)loadView{

//    [[NSUserDefaults standardUserDefaults] setObject: self.key forKey: @"OpenDocumentKey"];
//    self.current = (int)[[NSUserDefaults standardUserDefaults]integerForKey:self.key];
    if (self.current < 0 || self.current >= fz_count_pages(ctx, self.docRef.doc))
        self.current = 0;
    
    UIView *view = [[UIView alloc] initWithFrame: CGRectZero];
    [view setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [view setAutoresizesSubviews: YES];
    view.backgroundColor = [UIColor grayColor];
    
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
    UIPinchGestureRecognizer *pinchRecog = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
    pinchRecog.delegate = self;
    [self.canvas addGestureRecognizer:pinchRecog];

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
    
    [self setView:view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clickNumber = 1;
    self.rotatingBtnView = [[RotatingButtonView alloc]initWithFrame:CGRectMake(0, 64, 60, 90)];
    self.rotatingBtnView.delegate = self;
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    [win addSubview:self.rotatingBtnView];
    
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

    CGSize size = [self.canvas frame].size;
    int max_width = fz_max(self.width, size.width);
    
    self.width = size.width;
    self.height = size.height;
    
    [self.canvas setContentInset: UIEdgeInsetsZero];
    [self.canvas setContentSize: CGSizeMake(fz_count_pages(ctx, self.docRef.doc) * self.width, self.height)];
    [self.canvas setContentOffset: CGPointMake(self.current * self.width, 0)];
    
    // use max_width so we don't clamp the content offset too early during animation
    [self.canvas setContentSize: CGSizeMake(fz_count_pages(ctx, self.docRef.doc) * max_width, self.height)];
    [self.canvas setContentOffset: CGPointMake(self.current * self.width, 0)];
    
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
        self.view.backgroundColor = nightMode?[UIColor redColor]:[UIColor lightGrayColor];
    
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
    switchBtn.on = [[NSUserDefaults standardUserDefaults]boolForKey:@"switchNight"];
    NSLog(@"%d",[[NSUserDefaults standardUserDefaults]boolForKey:@"switchNight"]);
    [switchBtn addTarget:self action:@selector(onSwitchNight:) forControlEvents:UIControlEventValueChanged];
    
    return [[UIBarButtonItem alloc]initWithCustomView:switchBtn];
}

-(void)createPageViewWith:(int)number{
    if (number < 0 || number >= fz_count_pages(ctx, self.docRef.doc)){
        return;
    }

    int found = 0;
    for (UIView<MuPageView> *view in [self.canvas subviews])
        if ([view pageNumber] == number)
            found = 1;
    CGRect rect = CGRectMake(number * self.width, 0, self.width , self.height);
    if (!found) {
//        NSLog(@"nightMode==%d",self.nightMode);
       UIView<MuPageView> *view = [[MuNormalPageView alloc] initWithFrame:rect
                                                    andDocument:self.docRef
                                                  andPageNumber:number
                                                   andNightMode:self.nightMode];
        [view setScale:self.scale];
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

    self.rotatingBtnView.hidden = YES;
    sender.selected = !sender.selected;

    if (sender.selected) {
        
        [self showAnnotationMenu];
        
    }else{
    
        self.barmode =  BARMODE_MAIN;
    }
    
}

- (void) onInk: (id)sender
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
                    [view saveSelectionAsMarkup:FZ_ANNOT_HIGHLIGHT];
                    break;
                    
                case BARMODE_UNDERLINE:
                    [view saveSelectionAsMarkup:FZ_ANNOT_UNDERLINE];
                    break;
                    
                case BARMODE_STRIKE:
                    [view saveSelectionAsMarkup:FZ_ANNOT_STRIKEOUT];
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
    
     [[NSUserDefaults standardUserDefaults]setBool:sender.isOn forKey:@"switchNight"];
//    NSLog(@"switchNight==%d",[[NSUserDefaults standardUserDefaults]boolForKey:@"switchNight"]);
    [self createPageViewWith:self.current];
    
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
        //        NSLog(@"%@",self.canvas.subviews);
        if ([view pageNumber] == self.current) {
            
            [view removeFromSuperview];
            //            NSLog(@"%@",self.canvas.subviews);
        }
    }
}

#pragma mark --通知
-(void)loadPage{

    [self deleteCurrentPage];
    [self createPageViewWith:self.current];
    
//    [self.canvas layoutIfNeeded];
}

#pragma mark RotatingButtonViewDelegate

-(void)rotatingButtonView:(UIView *)rotatingView clickRotatingButton:(UIButton *)rotatingBtn{

    [[NSNotificationCenter defaultCenter]postNotificationName:rotationView object:nil userInfo:@{@"clickNumber":@(self.clickNumber)}];
    self.replyClickNum = self.clickNumber;
    self.clickNumber ++;
}

-(void)rotatingButtonView:(UIView *)rotatingView clickReplyButton:(UIButton *)replyButton{
    self.replyClickNum --;
    if (self.replyClickNum < 0) {
        self.replyClickNum = 0;
        return;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:rotationView object:nil userInfo:@{@"clickNumber":@(self.replyClickNum)}];
    self.clickNumber --;
}

-(void)viewTransformWithClickNumber:(int)clickNum{
    

}

#pragma mark -- scrollviewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    float x = [self.canvas contentOffset].x + self.width * 0.5f;
    self.current = x / self.width;

  
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
    
    self.docRef = nil; self.docRef.doc = NULL;
    self.indicator = nil;
    self.filePath = NULL;
    NSLog(@"+++");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark --UIGestureDelegate
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // For reflow mode, we load UIWebViews into the canvas. Returning YES
    // here prevents them stealing our tap and pinch events.
    return YES;
}
- (void) onTap: (UITapGestureRecognizer*)sender
{
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
        [view deselectAnnotation];
        CGPoint pp = [sender locationInView:view];
        if (CGRectContainsPoint(view.bounds, pp))
        {
            MuTapResult *result = [view handleTap:pp];
            __block BOOL hitAnnot = NO;
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
            }];
            
            switch (self.barmode)
            {
                case BARMODE_ANNOTATION:
                    if (hitAnnot)
                        [self deleteModeOn];
                    tapHandled = YES;
                    break;
                    
                case BARMODE_DELETE:
                    if (!hitAnnot)
                        [self showAnnotationMenu];
                    tapHandled = YES;
                    break;
                    
                default:
                    if (hitAnnot)
                    {
                        // Annotation will have been selected, which is wanted
                        // only in annotation-editing mode
                        [view deselectAnnotation];
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
        if ([[self navigationController] isNavigationBarHidden])
            [self showNavigationBar];
        else if (self.barmode == BARMODE_MAIN)
            [self hideNavigationBar];
    }
    
}
- (void) onPinch:(UIPinchGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
        sender.scale = self.scale;
    
    if (sender.scale < MIN_SCALE)
        sender.scale = MIN_SCALE;
    
    if (sender.scale > MAX_SCALE)
        sender.scale = MAX_SCALE;
    if (sender.state == UIGestureRecognizerStateEnded)
        self.scale = sender.scale;
    
    for (UIView<MuPageView> *view in [self.canvas subviews])
    {
        // Zoom only the visible page until end of gesture
        if (view.pageNumber == self.current || sender.state == UIGestureRecognizerStateEnded)
            [view setScale:sender.scale];
    }
    
}

@end
