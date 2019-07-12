//
//  DrawViewController.m
//  EFBMuPDF
//
//  Created by 赖永鹏 on 2019/7/4.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import "DrawViewController.h"
#import "DrawView.h"



@interface DrawViewController ()<UIAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong,nonatomic)UIToolbar *toolBar;
@property (strong,nonatomic)NSMutableDictionary *DicM;
@property (nonatomic, strong) DrawView *drawView;
@property (nonatomic, assign) BOOL isSave;
@end

@implementation DrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置偏好
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"isDefualtColor"];
    [userDefaults setBool:YES forKey:@"isDefualtLine"];
    [userDefaults synchronize];
    
    [self newImageWithSize:CGSizeMake(PHOTO_RECT.size.width, PHOTO_RECT.size.height) color:[UIColor clearColor]];
    UIImage *image = [UIImage imageWithContentsOfFile:signaturePathClear];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//    创建一个DrawView
    self.drawView = [[DrawView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - PHOTO_RECT.size.width)/2, (self.view.frame.size.height - PHOTO_RECT.size.height)/2, PHOTO_RECT.size.width, PHOTO_RECT.size.height)];
    [self.view addSubview:self.drawView];
    self.drawView.isUndo = NO;
    self.drawView.backgroundColor = [UIColor whiteColor];
    //创建工具栏对象
    self.toolBar = [[UIToolbar alloc]init];
    self.toolBar.barTintColor = [UIColor brownColor];
    self.toolBar.frame = CGRectMake((self.view.frame.size.width - PHOTO_RECT.size.width)/2,  self.drawView.frame.origin.y - 64, self.drawView.frame.size.width, 64);
   
    //创建工具栏项目
    UIBarButtonItem *clearpartItem = [[UIBarButtonItem alloc]initWithTitle:@"橡皮" style:UIBarButtonItemStylePlain target:self action:@selector(ClearPart:)];
    
    UIBarButtonItem *backdoneItem = [[UIBarButtonItem alloc]initWithTitle:@"撤销" style:UIBarButtonItemStylePlain target:self action:@selector(BackDone:)];
    
    UIBarButtonItem *clearallItem = [[UIBarButtonItem alloc]initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(ClearAll:)];

    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(Save:)];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

     [self.toolBar setItems:@[flexibleItem,clearpartItem,flexibleItem,backdoneItem,flexibleItem,clearallItem,flexibleItem,saveItem,flexibleItem,closeItem]];
    
    [self.view addSubview:self.toolBar];
    
    self.drawView.image = image;
    self.drawView.isUndo = NO;
    //创建路径
    self.drawView.path = CGPathCreateMutable();
    self.isSave = NO;
}
/**返回一张指定大小,指定颜色的图片*/
- (UIImage *)newImageWithSize:(CGSize) size color:(UIColor *)color
{
    // UIGrphics
    // 设置一个frame
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    // 开启图形绘制
    UIGraphicsBeginImageContext(size);
    
    // 获取当前图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 设置填充颜色
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    // 填充
    CGContextFillRect(context, rect);
    
    // 从当前图形上下文中获取一张透明图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭图形绘制
    UIGraphicsEndImageContext();
    
    return img;
}
-(void)close:(UIBarButtonItem *)sender{
    if (!_isSave) {
        
        UIAlertController *alertvc = [UIAlertController alertControllerWithTitle:@"是否需要保存" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self Save:nil];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertvc addAction:sure];
        [alertvc addAction:cancel];
        
        [self presentViewController:alertvc animated:YES completion:nil];
    }

}
//橡皮擦除(其实就是用白色重绘)
-(void)ClearPart:(UIBarButtonItem *)sender
{
    UIColor *selectedcolor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ColorNitification" object:selectedcolor];
    
    NSNumber *number = [NSNumber numberWithInteger:10];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"WidthNitification" object:number];
    
    //重设偏好
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDefualtColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDefualtLine"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//撤销
-(void)BackDone:(UIBarButtonItem *)sender
{
    //先做清理工作
    MyPath *path = [self.drawView.paths lastObject];
    CGPathRelease(path.path);
    
    //删除最后一个路径
    [self.drawView.paths removeLastObject];
    self.drawView.image = nil;
    
    self.drawView.isUndo = YES;
    
    //让视图重绘
    [self.view setNeedsDisplay];
}
//清空绘图
-(void)ClearAll:(UIBarButtonItem *)sender
{
    //先做清理工作
    for(MyPath *path in (self.drawView.paths))
    {
        CGPathRelease(path.path);
    }
    //删除所有
    [self.drawView.paths removeAllObjects];
    self.drawView.image = nil;
    
    self.drawView.isUndo = YES;
    
    //让视图重绘
    [self.view setNeedsDisplay];
}
//保存绘图
-(void)Save:(UIBarButtonItem *)sender
{
    [self didSelectedSave];
    self.isSave = YES;
    self.synImagesBlock();
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)didSelectedSave
{
    //开始图像绘制上下文
    UIGraphicsBeginImageContext(self.drawView.bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 先画保存的path
    for(MyPath *myPath in (self.drawView.paths))
    {
        if(myPath.image)
        {
            [myPath.image drawInRect: PHOTO_RECT ];
        }
        
        CGContextAddPath(context, myPath.path);
        [myPath.color set];
        CGContextSetLineWidth(context, myPath.lineWidth);
        CGContextStrokePath(context);
    }
    
    //获取绘制的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束图像绘制上下文
    UIGraphicsEndImageContext();
    
    BOOL result = [UIImagePNGRepresentation(image) writeToFile:signaturePath atomically:YES];
    NSLog(@"result == %d",result);

}

//按钮事件是否显示工具栏
-(void)showToolBar:(UIButton *)sender
{
    self.toolBar.hidden = !self.toolBar.hidden;
}

@end
