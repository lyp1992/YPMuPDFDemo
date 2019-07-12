//
//  SiniSearchProtocol.h
//  EFBMuPDF
//
//  Created by zyc on 2019/7/9.
//  Copyright © 2019 LYP. All rights reserved.
//

#ifndef SiniSearchProtocol_h
#define SiniSearchProtocol_h

@class PageStringModel;

@protocol SiniSearchDelegate <NSObject>

/**
 *  搜索内容
 */
- (NSArray <PageStringModel *> *)searchWithString:(NSString *)string model:(PageStringModel *)model;

/**
 *  显示搜索详细信息
 */
- (void)showSearchDetailWithModel:(PageStringModel *)model;

//搜索 会开启子线程
-(void)searchPdfWorfs:(NSString *)text fromIndex:(int)index progress:(void(^)(int total,int currentIndex))progress withResult:(void(^)(NSArray *results))result;

@end

#endif /* SiniSearchProtocol_h */
