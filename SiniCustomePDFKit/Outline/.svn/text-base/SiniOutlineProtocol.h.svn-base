//
//  SiniOutlineProtocol.h
//  EFBMuPDF
//
//  Created by zyc on 2019/7/10.
//  Copyright © 2019 LYP. All rights reserved.
//

#ifndef SiniOutlineProtocol_h
#define SiniOutlineProtocol_h
@class PagesModel;
@protocol SiniOutlineDelegate <NSObject>

/**
 *  跳转
 */
- (void)didClickedOutlineWithModel:(PagesModel *)model;

/**
 *  获取目录
 */
- (NSArray <PagesModel *> *)getChildsOutlineWithModel:(PagesModel *)model;

@end

#endif /* SiniOutlineProtocol_h */
