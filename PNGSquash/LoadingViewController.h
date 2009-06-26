//
//  LoadingViewController.h
//  PNGSquash
//
//  Created by Michael on 6/23/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import <Cocoa/Cocoa.h>
@class TableData;

@interface LoadingViewController : NSViewController
{
	id delegate;
	IBOutlet TableData *tableView;
	IBOutlet NSButton *button;
	IBOutlet NSProgressIndicator *spinner;
	IBOutlet NSTextField *textField;
	BOOL cancelled;

	NSSize oldSize;
	NSView *oldContentView;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, readonly) NSTableView *tableView;
@property (nonatomic, readonly) NSProgressIndicator *spinner;
@property (nonatomic, readonly) NSTextField *textField;

- (IBAction)cancel:(NSButton *)sender;
- (void)done:(NSButton *)sender;

- (void)resetViewToDefaults;
- (void)setAsContentViewFor:(NSWindow *)window;
- (void)resetContentView;
- (void)finishLoading;

@end
