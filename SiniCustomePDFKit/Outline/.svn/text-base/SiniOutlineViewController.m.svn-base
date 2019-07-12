//
//  SiniSearchViewController.m
//  SiniCustomePDFKit
//
//  Created by zyc on 2019/7/9.
//  Copyright © 2019 LYP. All rights reserved.
//

#import "SiniOutlineViewController.h"
#import "PagesModel.h"
#import <objc/runtime.h>

#define kRowHeight  60
#define kBlankWith  30

static const char * siniOutlineDataSourceIdentify = "siniOutlineDataSourceIdentify";

@interface SiniOutlineModel : PagesModel;

@property(nonatomic) BOOL isOpen;

@property(nonatomic) NSMutableArray <SiniOutlineModel *> *childOutlines;

@end
@implementation SiniOutlineModel

- (SiniOutlineModel *)mapWithPagesModel:(PagesModel *)pageModel{
    if (pageModel) {
        self.title = pageModel.title;
        self.level = pageModel.level;
        self.isSubOutline = pageModel.isSubOutline;
        self.page = pageModel.page;
        self.downOutline = pageModel.downOutline;
        self.nextOutline = pageModel.nextOutline;
        self.childOutlines = [NSMutableArray array];
        self.isOpen = NO;
    }
    return self;
}

@end

@interface SiniOutlineViewController () <UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic) UILabel *titleLabel;
@property(nonatomic) UITableView *tableView;

@property(nonatomic) NSMutableArray *dataSource;

@end

@implementation SiniOutlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.tableView];
    if (self.delegate) {
        NSMutableArray *array = (NSMutableArray *)[self.delegate getChildsOutlineWithModel:nil];
        NSMutableArray *dataSources = [NSMutableArray array];
        for (PagesModel *pageModel in array) {
            SiniOutlineModel *model = [[SiniOutlineModel alloc]init];
            [model mapWithPagesModel:pageModel];
            [dataSources addObject:model];
        }
        self.dataSource = dataSources;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
#pragma mark - get
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _titleLabel.text = @"目录";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _titleLabel;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.titleLabel.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-self.titleLabel.frame.size.height) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.estimatedRowHeight = 0;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
- (NSArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

#pragma mark - set



#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kRowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    SiniOutlineModel *outlineModel = self.dataSource[indexPath.row];
    //左侧箭头
    UIButton *indicateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    indicateButton.frame = CGRectMake(20 + outlineModel.level *kBlankWith, 0, 50, kRowHeight);
    indicateButton.tag = 10000 + indexPath.row;
    [indicateButton setTitle:@">" forState:UIControlStateNormal];
    [indicateButton setTitleColor:[UIColor colorWithRed:19.0f/255 green:130.0/255 blue:190.0/255 alpha:1] forState:UIControlStateNormal];
    [indicateButton addTarget:self action:@selector(indicateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:indicateButton];
    //关联数据源
    objc_setAssociatedObject(indicateButton, &siniOutlineDataSourceIdentify, outlineModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
        //是否隐藏指示器
    indicateButton.hidden = !outlineModel.isSubOutline;
        //初始化指示器方向
    CGFloat angle = outlineModel.isOpen ? M_PI/2 : 0;
    indicateButton.transform = CGAffineTransformMakeRotation(angle);
    //右边页码
    UILabel *pageNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width - 20 - 50, 0, 50, kRowHeight)];
    pageNumberLabel.text = [@(outlineModel.page + 1) stringValue];
    pageNumberLabel.textAlignment = NSTextAlignmentRight;
    pageNumberLabel.textColor = [UIColor grayColor];
    [cell.contentView addSubview:pageNumberLabel];
    
    //中间内容
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(indicateButton.frame), 0, self.tableView.frame.size.width- CGRectGetMaxX(indicateButton.frame) - 20 - pageNumberLabel.frame.size.width, kRowHeight)];
    titleLabel.text = outlineModel.title;
    titleLabel.textColor = [UIColor blackColor];
    [cell.contentView addSubview:titleLabel];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate) {
        SiniOutlineModel *model = self.dataSource[indexPath.row];
        [self.delegate didClickedOutlineWithModel:model];
    }
}
- (void)indicateButtonClicked:(UIButton *)sender{
    if (!self.delegate) return;
    
    SiniOutlineModel *outlineModel  = objc_getAssociatedObject(sender, &siniOutlineDataSourceIdentify);
    NSUInteger index = [self.dataSource indexOfObject:outlineModel];
    if (index>= self.dataSource.count) return;
    if (!outlineModel.isSubOutline) {//没有子目录
        //跳转到那一页
        if (self.delegate) {
            [self.delegate didClickedOutlineWithModel:outlineModel];
        }
        return;
    }
    
    if (!outlineModel.isOpen) {
        //未展开时，展开
            //展开cell
        NSMutableArray *models = (NSMutableArray *)[self.delegate getChildsOutlineWithModel:outlineModel];
        NSMutableArray *dataSources = [NSMutableArray array];
        for (PagesModel *pageModel in models) {
            SiniOutlineModel *model = [[SiniOutlineModel alloc]init];
            [model mapWithPagesModel:pageModel];
            [dataSources addObject:model];
        }
        outlineModel.childOutlines = dataSources;
        NSIndexSet *sets = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index+1, models.count)];
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSUInteger i = 0; i < models.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+i+1 inSection:0];
            [indexPaths addObject:indexPath];
        }
        [self.dataSource insertObjects:dataSources atIndexes:sets];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
            //展开指示器
        [UIView animateWithDuration:0.2f animations:^{
            sender.transform = CGAffineTransformMakeRotation(M_PI/2);
        }];
        outlineModel.isOpen = YES;
    }else{//展开时，收回
        if (outlineModel.childOutlines.count == 0) {
            return;
        }
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSMutableArray *outLinesArray = [NSMutableArray array];
        [self getChildOutlinesWithOutlineModel:outlineModel array:outLinesArray];
        
        for (SiniOutlineModel *outline in outLinesArray) {
            NSUInteger index = [self.dataSource indexOfObject:outline];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [indexPaths addObject:indexPath];
        }
        [self.dataSource removeObjectsInArray:outLinesArray];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
        //收回指示器
        [UIView animateWithDuration:0.2f animations:^{
            sender.transform = CGAffineTransformMakeRotation(0);
        }];
        outlineModel.isOpen = NO;
    }
    
    
}
- (void)getChildOutlinesWithOutlineModel:(SiniOutlineModel *)model array:(NSMutableArray*)outLines{
    if (model.childOutlines.count==0) {
        return ;
    }
    [outLines addObjectsFromArray:model.childOutlines];
    for (SiniOutlineModel *outline in model.childOutlines) {
        [self getChildOutlinesWithOutlineModel:outline array:outLines];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
