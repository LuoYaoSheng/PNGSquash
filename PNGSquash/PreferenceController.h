//
//  PreferenceController.h
//  PNGSquash
//
//  Created by Michael on 6/27/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import <Cocoa/Cocoa.h>

extern NSString * const pngoutPathChangedNotification;

@interface PreferenceController : NSWindowController
{
	IBOutlet NSTextField *browseField;
}

- (IBAction)browse:(id)sender;
- (IBAction)editTextField:(id)sender;

@end
