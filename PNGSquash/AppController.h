//
//  AppController.h
//  PNGSquash
//
//  Created by Michael Sanders on 6/14/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "ImageCompressor.h"
@class DragView;
@class LoadingViewController;
@class PreferenceController;

extern NSString * const windowPosKey;
extern NSString * const squashLevelKey;
extern NSString * const pngoutPathKey;

@interface AppController : NSObject <ImageCompressorDelegate>
{
	IBOutlet DragView *dragView;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSView *mainView;
	IBOutlet NSWindow *configureSheet;
	IBOutlet NSSlider *levelSlider;

	NSArray *imagefiles;
	NSString *pngoutPath;
	ImageCompressor *images;
	unsigned int fileCount;
	PreferenceController *preferenceController;
	LoadingViewController *loadingViewController;
}

- (IBAction)openFile:(id)sender;
- (IBAction)showMainWindow:(id)sender;
- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)compressFiles:(id)sender;
- (IBAction)cancelSheet:(id)sender;
- (void)setPngoutPath:(NSString *)path;
- (void)showConfigureSheet;
- (void)cleanupView;

@end
