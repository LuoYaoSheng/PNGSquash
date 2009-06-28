//
//  PreferenceController.m
//  PNGSquash
//
//  Created by Michael on 6/27/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import "PreferenceController.h"

NSString * const pngoutPathChangedNotification = @"pngoutPathChanged";

@implementation PreferenceController

- (id)init
{
	if (![super initWithWindowNibName:@"Preferences"])
		return nil;
	return self;
}

- (void)awakeFromNib
{
	DLog(@"preferenceController awoken from nib");
}

- (IBAction)browse:(id)sender
{
	NSOpenPanel *openDialog = [NSOpenPanel openPanel];

	[openDialog setCanChooseDirectories:NO];
	[openDialog setAllowsMultipleSelection:NO];
	[openDialog setTitle:@"Where is PNGOut?"];

	[openDialog setDirectory:[browseField stringValue]];

	if ([openDialog runModal] == NSOKButton) {
		[browseField setStringValue:[[openDialog filenames] objectAtIndex:0]];
	}
}

- (IBAction)editTextField:(id)sender
{
	if (![[sender stringValue] isEqualToString:@""]) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc postNotificationName:pngoutPathChangedNotification object:[sender stringValue]];
	}
}

@end
