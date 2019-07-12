//
//  MuOutlineController.h
//  YPMuPDFDemo
//
//  Created by 赖永鹏 on 2019/6/27.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MuOutlineController : UITableViewController
- (instancetype) initWithTarget: (id)aTarget titles: (NSMutableArray*)aTitles pages: (NSMutableArray*)aPages;

@end

NS_ASSUME_NONNULL_END
