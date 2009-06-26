//
//  DragView.m
//  PNGSquash
//
//  Created by Michael Sanders on 6/14/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import "DragView.h"
#import "DottedView.h"

@implementation DragView

@synthesize delegate;

- (void)dealloc
{
    [self unregisterDraggedTypes];
	[delegate release];
    [super dealloc];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	if ([delegate respondsToSelector:@selector(draggingEntered:)]) {
		unsigned int retVal = [delegate draggingEntered:sender];
		if (retVal == NSDragOperationCopy) {
			[dottedView setDimmed:YES];
			[dottedView setAnimateDashes:YES];
		}
		return retVal;
	}

	return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	[self draggingExited:nil];
	return [delegate respondsToSelector:@selector(performDragOperation:)]
	         && [delegate performDragOperation:sender];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	if ([dottedView dimmed]) {
		[dottedView setDimmed:NO];
		[dottedView setAnimateDashes:NO];
	}
}

@end
