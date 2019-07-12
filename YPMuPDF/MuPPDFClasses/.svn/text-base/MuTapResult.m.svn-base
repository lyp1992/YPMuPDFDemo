//
//  MuTapResult.m
//  YPMuPDFDemo
//
//  Created by navchina on 2017/7/7.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "MuTapResult.h"

@implementation MuTapResult
-(void) switchCaseInternal:(void (^)(MuTapResultInternalLink *))internalLinkBlock caseExternal:(void (^)(MuTapResultExternalLink *))externalLinkBlock caseRemote:(void (^)(MuTapResultRemoteLink *))remoteLinkBlock caseWidget:(void (^)(MuTapResultWidget *))widgetBlock caseAnnotation:(void (^)(MuTapResultAnnotation *))annotationBlock {}
@end

@implementation MuTapResultInternalLink
{
    int pageNumber;
}

@synthesize pageNumber;

-(id) initWithPageNumber:(int)aNumber
{
    self = [super init];
    if (self)
    {
        pageNumber = aNumber;
    }
    return self;
}

-(void) switchCaseInternal:(void (^)(MuTapResultInternalLink *))internalLinkBlock caseExternal:(void (^)(MuTapResultExternalLink *))externalLinkBlock caseRemote:(void (^)(MuTapResultRemoteLink *))remoteLinkBlock caseWidget:(void (^)(MuTapResultWidget *))widgetBlock caseAnnotation:(void (^)(MuTapResultAnnotation *))annotationBlock
{
    internalLinkBlock(self);
}

@end

@implementation MuTapResultExternalLink
{
    NSString *url;
}

@synthesize url;

-(id) initWithUrl:(NSString *)aString
{
    self = [super init];
    if (self)
    {
        url = aString;
    }
    return self;
}



-(void) switchCaseInternal:(void (^)(MuTapResultInternalLink *))internalLinkBlock caseExternal:(void (^)(MuTapResultExternalLink *))externalLinkBlock caseRemote:(void (^)(MuTapResultRemoteLink *))remoteLinkBlock caseWidget:(void (^)(MuTapResultWidget *))widgetBlock caseAnnotation:(void (^)(MuTapResultAnnotation *))annotationBlock
{
    externalLinkBlock(self);
}

@end

@implementation MuTapResultRemoteLink
{
    NSString *fileSpec;
    int pageNumber;
    BOOL newWindow;
}

@synthesize fileSpec, pageNumber, newWindow;

-(id) initWithFileSpec:(NSString *)aString pageNumber:(int)aNumber newWindow:(BOOL)aBool
{
    self = [super init];
    if (self)
    {
        fileSpec = aString;
        pageNumber = aNumber;
        newWindow = aBool;
    }
    return self;
}



-(void) switchCaseInternal:(void (^)(MuTapResultInternalLink *))internalLinkBlock caseExternal:(void (^)(MuTapResultExternalLink *))externalLinkBlock caseRemote:(void (^)(MuTapResultRemoteLink *))remoteLinkBlock caseWidget:(void (^)(MuTapResultWidget *))widgetBlock caseAnnotation:(void (^)(MuTapResultAnnotation *))annotationBlock
{
    remoteLinkBlock(self);
}

@end

@implementation MuTapResultWidget

-(void) switchCaseInternal:(void (^)(MuTapResultInternalLink *))internalLinkBlock caseExternal:(void (^)(MuTapResultExternalLink *))externalLinkBlock caseRemote:(void (^)(MuTapResultRemoteLink *))remoteLinkBlock caseWidget:(void (^)(MuTapResultWidget *))widgetBlock caseAnnotation:(void (^)(MuTapResultAnnotation *))annotationBlock
{
    widgetBlock(self);
}

@end

@implementation MuTapResultAnnotation
{
    MuAnnotation *annot;
}

@synthesize annot;

-(id) initWithAnnotation:(MuAnnotation *)aAnnot
{
    self = [super init];
    if (self)
    {
        annot = aAnnot;
    }
    return self;
}

-(void) switchCaseInternal:(void (^)(MuTapResultInternalLink *))internalLinkBlock caseExternal:(void (^)(MuTapResultExternalLink *))externalLinkBlock caseRemote:(void (^)(MuTapResultRemoteLink *))remoteLinkBlock caseWidget:(void (^)(MuTapResultWidget *))widgetBlock caseAnnotation:(void (^)(MuTapResultAnnotation *))annotationBlock
{
    annotationBlock(self);
}

@end

