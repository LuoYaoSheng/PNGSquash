//
//  LoadingViewController.m
//  PNGSquash
//
//  Created by Michael on 6/23/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import "LoadingViewController.h"
#import "TableData.h"

@implementation LoadingViewController

- (id)init
{
	return [super initWithNibName:@"Loading" bundle:nil];
}

- (void)dealloc
{
	[delegate release];
	[super dealloc];
}

@synthesize delegate;
@synthesize tableView;
@synthesize spinner;
@synthesize textField;

- (IBAction)cancel:(NSButton *)sender
{
	if (delegate && [delegate respondsToSelector:@selector(cancel:)]) {
		// Using performSelector: here gets rid of warnings about unknown method.
		cancelled = YES;
		[delegate performSelector:@selector(cancel:) withObject:sender];
	}
}

- (void)done:(NSButton *)sender
{
	[self resetViewToDefaults];
	[self resetContentView];
}

- (void)finishLoading
{
	if (cancelled) {
		[self done:nil];
		return;
	}

	[button setAction:@selector(done:)];
	[button setTitle:@"Done"];
	[button setKeyEquivalentModifierMask:0];
	[button setKeyEquivalent:@"\r"];
	[spinner setDoubleValue:[spinner maxValue]];
	[textField setStringValue:@"Finished compressing"];
}

// Resets all items in view to their original values
- (void)resetViewToDefaults
{
	cancelled = NO;
	[spinner setDoubleValue:0.0];
	[tableView clearAllRows];
	[[self view] unregisterDraggedTypes];

	[button setAction:@selector(cancel:)];
	[button setTitle:@"Cancel"];
	[button setKeyEquivalentModifierMask:NSCommandKeyMask];
	[button setKeyEquivalent:@"."];
	[textField setStringValue:@""];
}

// Sets loadingViewController's view as the contentView for the window, being
// careful to save & retain the old contentView first. Call resetContentView
// when finished.
- (void)setAsContentViewFor:(NSWindow *)window
{
	if ([window contentView] == [self view]) return;

	oldContentView = [window contentView];
	[oldContentView retain];
	NSView *blankView = [[NSView alloc] init];
	[window setContentView:blankView];

	NSRect windowFrame = [window frame];
	oldSize = windowFrame.size;
	NSView *loadingView = [self view];

	// Only resize when necessary
	NSSize newSize = [loadingView frame].size;
	windowFrame.size.height = oldSize.height > newSize.height ? oldSize.height
	                                                          : newSize.height;
	windowFrame.size.width = oldSize.width > newSize.width ? oldSize.width
	                                                       : newSize.width;

	windowFrame = [window frameRectForContentRect:windowFrame];
	[window setFrame:windowFrame display:YES animate:YES];

	[window setContentView:loadingView];
	[window setInitialFirstResponder:loadingView];
	[blankView release];
}

- (void)resetContentView
{
	NSView *loadingView = [self view];
	NSWindow *window = [loadingView window];
	NSView *blankView = [[NSView alloc] init];
	[window setContentView:blankView];

	NSRect windowFrame = [window frame];
	windowFrame.size = oldSize;
	[window setFrame:windowFrame display:YES animate:YES];
	[loadingView removeFromSuperview];
	[window setContentView:oldContentView];
	[window setInitialFirstResponder:oldContentView];

	[oldContentView release];
	oldContentView = nil;
	[blankView release];
}

@end
