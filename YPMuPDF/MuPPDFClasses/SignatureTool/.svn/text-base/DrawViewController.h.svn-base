//
//  DrawViewController.h
//  EFBMuPDF
//
//  Created by 赖永鹏 on 2019/7/4.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyPath.h"

#define signPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
#define signaturePathClear [signPath stringByAppendingPathComponent:@"signatureClear.png"]
#define signaturePath [signPath stringByAppendingPathComponent:@"signature.png"]

NS_ASSUME_NONNULL_BEGIN

typedef void(^SyntheticImages)();

@interface DrawViewController : UIViewController

@property (nonatomic,copy) SyntheticImages synImagesBlock;

@end

NS_ASSUME_NONNULL_END
