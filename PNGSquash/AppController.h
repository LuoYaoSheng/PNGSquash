//
//  AppController.h
//  PNGSquash
//
//  Created by Michael Sanders on 6/14/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import <Cocoa/Cocoa.h>
@class DragView;
@class ImageCompressor;
@class LoadingViewController;

extern NSString * const windowPosKey;
extern NSString * const squashLevelKey;

@interface AppController : NSObject
{
	IBOutlet DragView *dragView;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSView *mainView;
	IBOutlet NSWindow *configureSheet;
	IBOutlet NSSlider *levelSlider;

	NSArray *imagefiles;
	ImageCompressor *images;
	unsigned int fileCount;
	LoadingViewController *loadingViewController;
}

- (IBAction)openFile:(id)sender;
- (IBAction)showMainWindow:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)compressFiles:(id)sender;
- (IBAction)cancelSheet:(id)sender;
- (void)showConfigureSheet;
- (void)cleanupView;

@end
