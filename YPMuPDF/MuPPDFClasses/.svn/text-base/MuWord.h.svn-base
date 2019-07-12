//
//  MuWord.h
//  EFBMuPDF
//
//  Created by 赖永鹏 on 2019/6/28.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface MuWord : NSObject
@property(nonatomic,copy) NSString *string;
@property(nonatomic,assign) CGRect rect;
+ (MuWord *) word;
- (void) appendChar:(unichar)c withRect:(CGRect)rect;
+ (void) selectFrom:(CGPoint)pt1 to:(CGPoint)pt2 fromWords:(NSArray *)words onStartLine:(void (^)(void))startBlock onWord:(void (^)(MuWord *))wordBlock onEndLine:(void (^)(void))endBLock;
@end

NS_ASSUME_NONNULL_END
