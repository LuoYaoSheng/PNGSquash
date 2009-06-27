//
//  AppController.m
//  PNGSquash
//
//  Created by Michael Sanders on 6/14/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import "AppController.h"
#import "DragView.h"
#import "ImageCompressor.h"
#import "LoadingViewController.h"
#import "TableData.h"

NSString * const windowPosKey = @"LastWindowPosition";
NSString * const squashLevelKey = @"LastSquashLevel";

// Easy-to-use macro for alert errors
// NOTE: Remember, this is not modal
#define showAlertSheetWithError(error, window) [[NSAlert alertWithError:(error)] beginSheetModalForWindow:(window) modalDelegate:nil didEndSelector:NULL contextInfo:NULL]

@implementation AppController

- (void)awakeFromNib
{
	NSArray *types = [[NSArray alloc] initWithObjects:NSFilenamesPboardType, nil];
	[dragView registerForDraggedTypes:types];
	[types release];

	loadingViewController = [[LoadingViewController alloc] init];
	// loadingView is really a DragView; casting here removes a warning
	DragView *loadingView = (DragView *)[loadingViewController view];
	[loadingView setDelegate:self];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	// Move window to previous position
	NSString *coordinateString = [userDefaults valueForKey:windowPosKey];
	NSArray *coordinates = [coordinateString componentsSeparatedByString:@" "];
	if (coordinates != nil) {
		NSRect windowFrame = [mainWindow frame];
		windowFrame.origin.x = [[coordinates objectAtIndex:0] intValue];
		windowFrame.origin.y = [[coordinates objectAtIndex:1] intValue];
		[mainWindow setFrame:windowFrame display:NO];
	}

	// Change slider to previous position
	NSNumber *sliderValue = [userDefaults valueForKey:squashLevelKey];
	if (sliderValue != nil) {
		[levelSlider setIntValue:[sliderValue intValue]];
	}
}

- (void)dealloc
{
	[dragView setDelegate:nil];
	[NSApp setDelegate:nil];
	[super dealloc];
}

- (void)showConfigureSheet
{
	[NSApp beginSheet:configureSheet
	   modalForWindow:mainWindow
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}

- (IBAction)cancelSheet:(id)sender;
{
	[configureSheet orderOut:nil];
	[NSApp endSheet:configureSheet];
	[imagefiles release];
}

- (IBAction)compressFiles:(id)sender
{
	// Close sheet
	[configureSheet orderOut:nil];
	[NSApp endSheet:configureSheet];

	// The user dragged to the table view before pressing "Done"
	if ([loadingViewController view] == [mainWindow contentView]) {
		[loadingViewController resetViewToDefaults];
	} else { // The user dragged to the normal, dotted view
		[loadingViewController setAsContentViewFor:mainWindow];
	}

	[loadingViewController setDelegate:self];

	// Disable close button while compressing
	[[mainWindow standardWindowButton:NSWindowCloseButton] setEnabled:NO];

	fileCount = [imagefiles count];
	images = [[ImageCompressor alloc] init];
	[images setDelegate:self];

	// compressorCount is only initialized after this method
	[images compressFiles:imagefiles
				  atLevel:[levelSlider intValue]
		   didEndSelector:@selector(finishedCompressing:)
				   object:self];

	NSProgressIndicator *loadingSpinner = [loadingViewController spinner];
	[loadingSpinner setMaxValue:(fileCount * [images compressorCount]) + 1];

	[imagefiles release];
}

- (void)cleanupView
{
	[loadingViewController setDelegate:nil];
	[images release];
	images = nil;
	[loadingViewController finishLoading];
	[[mainWindow standardWindowButton:NSWindowCloseButton] setEnabled:YES];
}

#pragma mark LoadingViewController delegate

// User pressed cancel button on loadingView
- (void)cancel:(id)sender
{
	NSError *error = [images cancelCompressing];
	if (error != nil) {
		showAlertSheetWithError(error, mainWindow);
	}
	DLog(@"User pressed cancel.");
	[self cleanupView];
}

#pragma mark ImageCompressor delegate methods

- (void)finishedCompressing:(NSError *)error
{
	if (error != nil) {
		showAlertSheetWithError(error, mainWindow);
		// Hide view when done if error is shown.
		[loadingViewController setValue:[NSNumber numberWithBool:YES]
								 forKey:@"cancelled"];
	} else {
		// Allow dragging of PNGs once compression is finished.
		[[loadingViewController view] registerForDraggedTypes:
			[dragView registeredDraggedTypes]];
	}

	DLog(@"Finished compressing.");
	[self cleanupView];
}

- (BOOL)runCompressor:(NSString *)progname forFile:(int)filenum
{
	NSString *string = [[NSString alloc] initWithFormat:
		@"Running %@ on file %i of %i", progname, filenum, fileCount];
	[[loadingViewController textField] setStringValue:string];
	[[loadingViewController spinner] incrementBy:1.0];
	[string release];
	return YES;
}

- (void)compressedFile:(NSString *)infile toFile:(NSString *)outfile
{
	NSFileManager *manager = [NSFileManager defaultManager];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
		[outfile lastPathComponent], @"file",
		[[manager fileAttributesAtPath:infile
							  traverseLink:NO]
							  objectForKey:NSFileSize], @"oldsize",
		[[manager fileAttributesAtPath:outfile
							  traverseLink:NO]
							  objectForKey:NSFileSize], @"newsize", nil];

	// This is really the TableData class, not NSTableView
	TableData *tableView = (TableData *)[loadingViewController tableView];
	[tableView addRow:dict];
	[dict release];
}

#pragma mark NSApp delegate methods

// Show main window when app becomes active after being hidden.
- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
	[mainWindow makeKeyAndOrderFront:nil];
}

// User dragged items to dock icon
- (void)application:(NSApplication *)app openFiles:(NSArray *)filenames
{
	if (images != nil) return; // Skip when image is being compressed
	imagefiles = [filenames retain];
	[self showConfigureSheet];
}

// User tried to quit.
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	if (images != nil) {
		int button = NSRunAlertPanel(@"Quit without compressing?",
		                             @"An image is currently being compressed. "
									 @"Are you sure you want to quit?",
		                             @"Quit", @"Cancel", nil);
		if (button == NSCancelButton) {
			return NSTerminateCancel;
		}
		[self cancel:nil];
	}
	return NSTerminateNow;
}

// Save user defaults when app is quit
- (void)applicationWillTerminate:(NSNotification *)note
{
	// Save window coordinates
	NSPoint origin = [mainWindow frame].origin;
	NSString *points = [[NSString alloc] initWithFormat:@"%.f %.f", origin.x, origin.y];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:points forKey:windowPosKey];
	DLog(@"Saving coordinates: %@", points);
	[points release];

	// Save previous squash level
	NSNumber *sliderValue = [NSNumber numberWithInt:[levelSlider intValue]];
	[userDefaults setObject:sliderValue forKey:squashLevelKey];
	DLog(@"Saving squash level: %@", sliderValue);
}

#pragma mark Menu items

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
	SEL theAction = [anItem action];
	if (theAction == @selector(showMainWindow:)) {
		return ![mainWindow isVisible];
	} else if (theAction == @selector(openFile:)){
		// Disable File > Squash Image… when image is being compressed
		return images == nil;
	}
	return YES;
}

// File > Show Main Window
- (IBAction)showMainWindow:(id)sender
{
	[mainWindow makeKeyAndOrderFront:nil];
}


// File > Squash Image…
- (IBAction)openFile:(id)sender
{
	NSOpenPanel *openDialog = [NSOpenPanel openPanel];
	NSArray *filetypes = [[NSArray alloc] initWithObjects:@"png", nil];

	[openDialog setCanChooseDirectories:NO];
	[openDialog setAllowsMultipleSelection:YES];
	[openDialog setTitle:@"Choose a PNG to compress"];
	[openDialog setAllowedFileTypes:filetypes];

	if ([openDialog runModalForTypes:filetypes] == NSOKButton) {
		imagefiles = [[openDialog filenames] retain];
		[self showConfigureSheet];
	}

	[filetypes release];
}

// Help > PNGSquash Help
- (IBAction)showHelp:(id)sender
{
	NSRunAlertPanel(@"Help", @"Seriously? Just drag a PNG.",
	                @"Okay, fine!", nil, nil);
}

#pragma mark DragView delegate methods

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	NSPasteboard *paste = [sender draggingPasteboard];
	NSArray *fileArray = [paste propertyListForType:@"NSFilenamesPboardType"];

	for (NSString *fname in fileArray) {
		if (![[fname pathExtension] isEqualToString:@"png"]) {
			DLog(@"Not a png.");
			return NSDragOperationNone;
		}
	}
	return NSDragOperationCopy;

}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *paste = [sender draggingPasteboard];
	imagefiles = [[paste propertyListForType:@"NSFilenamesPboardType"] retain];
	[NSApp activateIgnoringOtherApps:YES];
	[self showConfigureSheet];

	return YES;
}

@end
