#import <UIKit/UIKit.h>
#import "MuTapResult.h"
#import "PreferencesModel.h"

#define rotationView @"rotationView"
#define reloadThePage @"reloadThePage"


#define signPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
#define signaturePathClear [signPath stringByAppendingPathComponent:@"signatureClear.png"]
#define signaturePath [signPath stringByAppendingPathComponent:@"signature.png"]

@protocol MuPageView
-(int) pageNumber;
-(void) willRotate;
-(void) showLinks;
-(void) hideLinks;
-(void) showSearchResults: (int)count;
-(void) clearSearchResults;
-(void) resetZoomAnimated: (BOOL)animated;
-(void) setScale:(float)scale;
-(MuTapResult *) handleTap:(CGPoint)pt;
-(void) textSelectModeOn;
-(void) textSelectModeOff;
-(void) deselectAnnotation;
-(void) deleteSelectedAnnotation;
-(void) inkModeOn;
-(void) inkModeOff;
-(void) saveSelectionAsMarkup:(int)type;
-(void) saveInk;
-(void) update;

-(void)yp_getPDFDirectionWithDegree:(CGFloat)degree;
-(void)saveAnnotsModel;
-(void)deleteCurrentCurves;
-(NSArray *)searchPageWords;

// 撤销
-(void)undo;
-(void)redo;
-(void)signature;
-(void)setPerfercesModel:(PreferencesModel *)preferModel;

@end

