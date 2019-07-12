//
//  ViewController.m
//  MuPDFDemo
//
//  Created by zhangsl on 2016/12/23.
//  Copyright © 2016年 zhangsl. All rights reserved.
//

#import "ViewController.h"
//#import "common.h"
#import "MuDocumentViewController.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *fileArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)[0];
    self.fileArr = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:filePath error:nil];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.tableView];
 
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.fileArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.textLabel.text = self.fileArr[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)[0];

    NSString *fileP = [filePath stringByAppendingPathComponent:self.fileArr[indexPath.row]];
    
    MuDocRef *docRef = [[MuDocRef alloc] initWithFilePath:fileP];
    
    //先从缓存中取，
    BOOL isNightModel = [[NSUserDefaults standardUserDefaults]boolForKey:@"switchNight"];
    MuDocumentViewController *document = [[MuDocumentViewController alloc] initWith:fileP andDocument: docRef andNightMode:isNightModel];
    
    [self.navigationController pushViewController:document animated:YES];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
