//
//  MuAnnotSelectView.h
//  YPMuPDFDemo
//
//  Created by navchina on 2017/7/7.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MuAnnotation.h"
#import "ToolView.h"
#import "QBPopupMenu.h"
#import "QBPlasticPopupMenu.h"

@class MuAnnotSelectView;
@protocol MuAnnotSelectViewDelegate <NSObject>

-(void)muAnnotSelectView:(MuAnnotSelectView*)view deleteAnnotSeletViewWithButton:(UIButton *)sender;

@end

@interface MuAnnotSelectView : UIView

- (id) initWithAnnot:(MuAnnotation *)_annot pageSize:(CGSize)_pageSize;

@property (nonatomic, weak) id<MuAnnotSelectViewDelegate>delegate;
@property(nonatomic, strong) ToolView *toolView;

@property (nonatomic, strong) QBPopupMenu *popupMenu;
@property (nonatomic, strong) QBPlasticPopupMenu *plasticPopupMenu;
@end
