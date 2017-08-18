//
//  MuDocRef.m
//  MuPDFDemo
//
//  Created by zhangsl on 2017/1/3.
//  Copyright © 2017年 zhangsl. All rights reserved.
//

#import "MuDocRef.h"

#import "common.h"

@implementation MuDocRef

-(instancetype)initWithFilePath:(NSString *)filePath{
    self = [super init];
    if (self) {
        fz_var(self);
        fz_try(ctx){
            self.doc = fz_open_document(ctx, filePath.UTF8String);
            if (!self.doc) {
                self = nil;
            }else{
                pdf_document *pdf_doc = pdf_specifics(ctx, self.doc);
                if (pdf_doc) {
                    pdf_enable_js(ctx, pdf_doc);
                    self.interactive = (pdf_doc != NULL) && (pdf_crypt_version(ctx, pdf_doc) == 0);
                }
            }
        }
        fz_catch(ctx){
            if (self) {
                fz_drop_document(ctx, self.doc);
            }
        }
    }
    return self;
}

@end
