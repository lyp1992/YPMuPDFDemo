//
//  SiniSearchViewController.m
//  SiniCustomePDFKit
//
//  Created by zyc on 2019/7/9.
//  Copyright © 2019 LYP. All rights reserved.
//

#import "SiniSearchViewController.h"
#import "PageStringModel.h"
#import "MJRefresh.h"

#define kRowHeight  180

@interface SiniSearchViewController () <UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic) UISearchBar *searchBar;
@property(nonatomic) UITableView *tableView;

@property(nonatomic) NSMutableArray *dataSource;

@property (nonatomic) UIProgressView *progressView;

@end

@implementation SiniSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.progressView];
    __block SiniSearchViewController *blockSelf = self;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (blockSelf.delegate && self.searchBar.text.length > 0) {
            PageStringModel *model;
            if (self.dataSource.count > 0) {
                model = self.dataSource.lastObject;
            }
            //            NSArray *subDataSource = [blockSelf.delegate searchWithString:self.searchBar.text model:model];
            //            [self.dataSource addObjectsFromArray:subDataSource];
            //            [self.tableView reloadData];
            
            [blockSelf.delegate searchPdfWorfs:self.searchBar.text fromIndex:model.pageNumber progress:^(int total, int currentIndex) {
                
                [blockSelf.progressView setProgress:(CGFloat)currentIndex/total animated:YES];
            } withResult:^(NSArray *results) {
                [blockSelf.progressView setProgress:0];
                blockSelf.dataSource = [NSMutableArray arrayWithArray:results];
                [blockSelf.tableView reloadData];
            }];
            
        }
        [self.tableView.mj_footer endRefreshing];
    }];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}
#pragma mark - get
- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchBar.placeholder = @"搜索文稿";
        _searchBar.returnKeyType = UIReturnKeySearch;
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _searchBar.frame.size.height+2, self.view.frame.size.width, self.view.frame.size.height - _searchBar.frame.size.height) style:UITableViewStyleGrouped];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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
-(UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]init];
        
        _progressView.frame = CGRectMake(1, _searchBar.frame.size.height, self.view.frame.size.width - 2, 2);
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _progressView.progressTintColor = [UIColor blueColor];
        
    }
    return _progressView;
}

#pragma mark - set


#pragma search bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchBar.text.length == 0) {
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    
    //    每次进来，删除原来的数据，重新搜索。
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
    self.progressView.progress = 0;
    if (self.delegate) {
        //        NSArray *array = [self.delegate searchWithString:searchBar.text model:nil];
        __weak typeof(self)weakSelf = self;
        [self.delegate searchPdfWorfs:searchBar.text fromIndex:0 progress:^(int total, int currentIndex) {
            
            [weakSelf.progressView setProgress:(CGFloat)currentIndex/total animated:YES];
        } withResult:^(NSArray *results) {
            [weakSelf.progressView setProgress:0];
            weakSelf.dataSource = [NSMutableArray arrayWithArray:results];
            [weakSelf.tableView reloadData];
        }];
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (self.delegate) {
        //        NSArray *array = [self.delegate searchWithString:searchBar.text model:nil];
        //        self.dataSource = [NSMutableArray arrayWithArray:array];
        //        [self.tableView reloadData];
        
        __weak typeof(self)weakSelf = self;
        [self.delegate searchPdfWorfs:searchBar.text fromIndex:0 progress:^(int total, int currentIndex) {
            
            [weakSelf.progressView setProgress:(CGFloat)currentIndex/total animated:YES];
        } withResult:^(NSArray *results) {
            [weakSelf.progressView setProgress:0];
            weakSelf.dataSource = [NSMutableArray arrayWithArray:results];
            [weakSelf.tableView reloadData];
        }];
    }
}
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    PageStringModel *model = self.dataSource[indexPath.row];
    //图片
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, (kRowHeight - 70)/2, 70, 70)];
    //#if DEBUG
    //    NSData * data = UIImagePNGRepresentation(model.pdfImage);
    //    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    //    NSString *uuid = [NSUUID UUID].UUIDString;
    //    NSString *fileName = [NSString stringWithFormat:@"%@.png",uuid];
    //    [data writeToFile:[docPath stringByAppendingPathComponent:fileName] atomically:YES];
    //#endif
    imageView.image = model.pdfImage;
    [cell.contentView addSubview:imageView];
    //页面
    UILabel *pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width - 40 - 20, 10, 40, 20)];
    pageLabel.font = [UIFont systemFontOfSize:14.0f];
    NSString *pageNumber = [@(model.pageNumber + 1) stringValue];
    pageLabel.text = [NSString stringWithFormat:@"页%@",pageNumber];
    pageLabel.textColor = [UIColor colorWithRed:19.0f/255 green:130.0/255 blue:190.0/255 alpha:1];//19 130 190
    [cell.contentView addSubview:pageLabel];
    //内容
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame), 30, self.tableView.frame.size.width - 70 - 20 - 20, kRowHeight - pageLabel.frame.size.height - 10 - 10)];
    contentLabel.numberOfLines = 0;
    contentLabel.attributedText = model.attributeString;
    [cell.contentView addSubview:contentLabel];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate) {
        PageStringModel *model = self.dataSource[indexPath.row];
        [self.delegate showSearchDetailWithModel:model];
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
