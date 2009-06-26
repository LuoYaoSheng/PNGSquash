//
//  DottedView.h
//  PNGSquash
//
//  Created by Michael Sanders on 6/14/09.
//  Copyright 2009 Me. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DottedView : NSView
{
	IBOutlet NSTextField *dropTextField;

	NSBezierPath *roundPath; // The dotted line surrounding the view
	NSBezierPath *arrowPoint; // The end of the drop arrow
	NSBezierPath *arrowLine; // Stem of the drop arrow

	NSColor *defaultWindowColor;
	NSTimer *animateTimer;
	NSTimer *notifyTimer;
	NSString *oldString;
	BOOL dimmed;
	int phase;
}

@property (nonatomic, readwrite, assign) BOOL dimmed;
- (void)setAnimateDashes:(BOOL)animate;

@end
