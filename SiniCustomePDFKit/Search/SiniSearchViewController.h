//
//  SiniSearchViewController.h
//  SiniCustomePDFKit
//
//  Created by zyc on 2019/7/9.
//  Copyright © 2019 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SiniSearchProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface SiniSearchViewController : UIViewController

@property(nonatomic,weak) id <SiniSearchDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
