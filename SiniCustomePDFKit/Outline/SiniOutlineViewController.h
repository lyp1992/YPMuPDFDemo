//
//  SiniSearchViewController.h
//  SiniCustomePDFKit
//
//  Created by zyc on 2019/7/9.
//  Copyright © 2019 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SiniOutlineProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface SiniOutlineViewController : UIViewController

@property(nonatomic) id <SiniOutlineDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
